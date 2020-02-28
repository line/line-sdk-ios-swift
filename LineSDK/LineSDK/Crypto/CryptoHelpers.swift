//
//  RSAHelpers.swift
//
//  Copyright (c) 2016-present, LINE Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LINE Corporation.
//
//  As with any software that integrates with the LINE Corporation platform, your use of this software
//  is subject to the LINE Developers Agreement [http://terms2.line.me/LINE_Developers_Agreement].
//  This copyright notice shall be included in all copies or substantial portions of the software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import CommonCrypto

extension Data {

    func x509HeaderStripped(earlyTerminator: UInt8) throws -> Data {
        let count = self.count / MemoryLayout<CUnsignedChar>.size
        guard count > 0 else {
            throw CryptoError.algorithmsFailed(reason: .invalidDERKey(data: self, reason: "The input key is empty."))
        }
        
        // Check the first byte
        var index = 0
        
        // If the first byte is already the terminator, just return.
        if self[index] == earlyTerminator { return self }
        
        guard self[index] == ASN1Type.sequence.byte else {
            throw CryptoError.algorithmsFailed(
                reason: .invalidDERKey(
                    data: self,
                    reason: "The input key is invalid. ASN.1 structure requires 0x30 (SEQUENCE) as its first byte"
                )
            )
        }
        
        // octets length
        index += 1
        if self[index] > 0x80 { // 0x80 == 128
            index += Int(self[index]) - 0x80 + 1
        } else {
            index += 1
        }
        
        // Check again for the terminator (for RSA, it should be an INTEGER).
        // There is no X509 header contained anymore. We could just return the input DER data as is.
        if self[index] == earlyTerminator { return self }
        
        // Handle X.509 key now. PKCS #1 rsaEncryption szOID_RSA_RSA, it should look like this:
        // 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00
        guard self[index] == ASN1Type.sequence.byte else {
            throw CryptoError.algorithmsFailed(
                reason: .invalidX509Header(
                    data: self, index: index, reason: "Expects byte 0x30, but found \(self[index])"
                )
            )
        }
        
        index += 1
        index += Int(self[index]) + 1
        guard self[index] == ASN1Type.bitString.byte else {
            throw CryptoError.algorithmsFailed(
                reason: .invalidX509Header(
                    data: self, index: index, reason: "Expects byte 0x03, but found \(self[index])"
                )
            )
        }
        
        index += 1
        if self[index] > 0x80 {
            index += Int(self[index]) - 0x80 + 1
        } else {
            index += 1
        }
        
        // End of header
        guard self[index] == 0 else {
            throw CryptoError.algorithmsFailed(
                reason: .invalidX509Header(
                    data: self, index: index, reason: "Expects byte 0x00, but found \(self[index])"
                )
            )
        }
        
        index += 1
        
        let strippedKeyBytes = [UInt8](self[index...self.count - 1])
        let data = Data(bytes: strippedKeyBytes, count: self.count - index)
        
        return data
    }
    
    /// Data with x509 stripped from a provided ASN.1 DER EC public key.
    /// The DER data will be returned as is, if no header contained.
    func x509HeaderStrippedForEC() throws -> Data {
        return try x509HeaderStripped(earlyTerminator: ASN1Type.uncompressedIndicator.byte)
    }
    
    /// Data with x509 stripped from a provided ASN.1 DER RSA public key.
    /// The DER data will be returned as is, if no header contained.
    /// We need to do this on Apple's platform for accepting a key.
    // http://blog.flirble.org/2011/01/05/rsa-public-key-openssl-ios/
    func x509HeaderStrippedForRSA() throws -> Data {
        return try x509HeaderStripped(earlyTerminator: ASN1Type.integer.byte)
    }
}

extension SecKey {
    
    enum KeyClass {
        case publicKey
        case privateKey
        
        var name: CFString {
            switch self {
            case .publicKey: return kSecAttrKeyClassPublic
            case .privateKey: return kSecAttrKeyClassPrivate
            }
        }
    }
    
    enum KeyType {
        case rsa
        case ec
        
        var name: CFString {
            switch self {
            case .rsa: return kSecAttrKeyTypeRSA
            case .ec: return kSecAttrKeyTypeECSECPrimeRandom
            }
        }
    }
    
    // Create a general key from DER raw data.
    static func createKey(derData data: Data, keyClass: KeyClass, keyType: KeyType) throws -> SecKey {
        let sizeInBits = data.count * MemoryLayout<UInt8>.size
        let attributes: [CFString: Any] = [
            kSecAttrKeyType: keyType.name,
            kSecAttrKeyClass: keyClass.name,
            kSecAttrKeySizeInBits: NSNumber(value: sizeInBits)
        ]
        
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(data as CFData, attributes as CFDictionary, &error) else {
            let reason = String(describing: error)
            throw CryptoError.algorithmsFailed(reason: .createKeyFailed(data: data, reason: reason))
        }
        
        return key
    }
    
    // Create a public key from some given certificate data.
    static func createPublicKey(certificateData data: Data) throws -> SecKey {
        guard let certData = SecCertificateCreateWithData(nil, data as CFData) else {
            throw CryptoError.algorithmsFailed(
                reason: .createKeyFailed(data: data, reason: "The data is not a valid DER-encoded X.509 certificate"))
        }
        
        // Get public key from certData
        let copyKey: (SecCertificate) -> SecKey?

        #if targetEnvironment(macCatalyst)
        copyKey = SecCertificateCopyKey
        #else
        if #available(iOS 12.0, *) {
            copyKey = SecCertificateCopyKey
        } else if #available(iOS 10.3, *) {
            copyKey = SecCertificateCopyPublicKey
        } else {
            throw CryptoError.generalError(
                reason: .operationNotSupported(
                    reason: "Loading public key from certificate not supported below iOS 10.3.")
            )
        }
        #endif

        guard let key = copyKey(certData) else {
            throw CryptoError.algorithmsFailed(
                reason: .createKeyFailed(data: data, reason: "Cannot copy public key from certificate"))
        }
        return key
    }
}

extension String {
    /// Returns a base64 encoded string with markers stripped.
    func markerStrippedBase64() throws -> String {
        var lines = components(separatedBy: "\n").filter { line in
            return !line.hasPrefix(RSA.Constant.beginMarker) && !line.hasPrefix(RSA.Constant.endMarker)
        }
        
        guard lines.count != 0 else {
            throw CryptoError.algorithmsFailed(
                reason: .invalidPEMKey(string: self, reason: "Empty PEM key after stripping.")
            )
        }
        
        // Strip off carriage returns in case.
        lines = lines.map { $0.replacingOccurrences(of: "\r", with: "") }
        return lines.joined(separator: "")
    }
}

extension RSA {
    struct Constant {
        static let beginMarker = "-----BEGIN"
        static let endMarker = "-----END"
    }
}

/// Possible ASN.1 types.
/// See https://en.wikipedia.org/wiki/Abstract_Syntax_Notation_One
/// for more information.
enum ASN1Type {
    case sequence
    case integer
    case bitString
    case uncompressedIndicator
    
    var byte: UInt8 {
        switch self {
        case .sequence: return 0x30
        case .integer: return 0x02
        case .bitString: return 0x03
        case .uncompressedIndicator: return 0x04
        }
    }
}
