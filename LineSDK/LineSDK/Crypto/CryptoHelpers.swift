//
//  RSAHelpers.swift
//
//  Copyright (c) 2016-present, LY Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LY Corporation.
//
//  As with any software that integrates with the LY Corporation platform, your use of this software
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

    /// Strips the X.509 certificate header information from a DER-encoded key data.
    ///
    /// This method processes X.509 formatted key data by:
    /// 1. Validating the input data and ASN.1 structure
    /// 2. Processing and removing X.509 header information
    /// 3. Extracting the actual key data
    ///
    /// The method handles the following ASN.1 structure:
    /// - Sequence tag (0x30)
    /// - Length encoding
    /// - PKCS #1 rsaEncryption identifier sequence
    ///
    /// - Parameter earlyTerminator: A byte marker used for early termination. For RSA keys, this is typically an INTEGER type marker
    /// - Returns: The processed key data with X.509 header removed
    /// - Throws: CryptoError if the input data format is invalid or processing fails
    func x509HeaderStripped(earlyTerminator: UInt8) throws -> Data {
        let count = self.count / MemoryLayout<CUnsignedChar>.size
        guard count > 0 else {
            throw CryptoError.algorithmsFailed(reason: .invalidDERKey(data: self, reason: "The input key is empty."))
        }
        
        // Initialize index for ASN.1 structure parsing
        var index = 0
        
        // Early return if the data is already in the correct format
        if self[index] == earlyTerminator { return self }
        
        // Validate ASN.1 sequence marker (0x30)
        guard self[index] == ASN1Type.sequence.byte else {
            throw CryptoError.algorithmsFailed(
                reason: .invalidDERKey(
                    data: self,
                    reason: "The input key is invalid. ASN.1 structure requires 0x30 (SEQUENCE) as its first byte"
                )
            )
        }
        
        // Process length field according to ASN.1 BER encoding rules:
        // - If length byte <= 0x80: direct length value
        // - If length byte > 0x80: subsequent bytes contain the length
        index += 1
        if self[index] > 0x80 { // 0x80 == 128
            index += Int(self[index]) - 0x80 + 1
        } else {
            index += 1
        }
        
        // Check for early terminator (INTEGER type for RSA keys)
        // If found, the data doesn't contain X.509 header
        if self[index] == earlyTerminator { return self }
        
        // Process X.509 key header
        // Expected PKCS #1 rsaEncryption identifier sequence:
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
    ///
    /// - Returns: The processed key data with X.509 header removed
    /// - Throws: CryptoError if the input data format is invalid or processing fails
    func x509HeaderStrippedForEC() throws -> Data {
        return try x509HeaderStripped(earlyTerminator: ASN1Type.uncompressedIndicator.byte)
    }
    
    /// Data with x509 stripped from a provided ASN.1 DER RSA public key.
    /// The DER data will be returned as is, if no header contained.
    /// We need to do this on Apple's platform for accepting a key.
    /// http://blog.flirble.org/2011/01/05/rsa-public-key-openssl-ios/
    ///
    /// - Returns: The processed key data with X.509 header removed
    /// - Throws: CryptoError if the input data format is invalid or processing fails
    func x509HeaderStrippedForRSA() throws -> Data {
        return try x509HeaderStripped(earlyTerminator: ASN1Type.integer.byte)
    }
}

extension SecKey {
    
    /// Enum representing the class of a key.
    enum KeyClass {
        case publicKey
        case privateKey
        
        /// Returns the corresponding CFString for the key class.
        var name: CFString {
            switch self {
            case .publicKey: return kSecAttrKeyClassPublic
            case .privateKey: return kSecAttrKeyClassPrivate
            }
        }
    }
    
    /// Enum representing the type of a key.
    enum KeyType {
        case rsa
        case ec
        
        /// Returns the corresponding CFString for the key type.
        var name: CFString {
            switch self {
            case .rsa: return kSecAttrKeyTypeRSA
            case .ec: return kSecAttrKeyTypeECSECPrimeRandom
            }
        }
    }
    
    /// Creates a general key from DER raw data.
    ///
    /// - Parameters:
    ///   - data: The DER-encoded key data.
    ///   - keyClass: The class of the key.
    ///   - keyType: The type of the key.
    ///
    /// - Returns: The created key.
    /// - Throws: CryptoError if the input data format is invalid or key creation fails
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
    
    /// Creates a public key from some given certificate data.
    ///
    /// - Parameters:
    ///   - data: The certificate data.
    ///
    /// - Returns: The created public key.
    /// - Throws: CryptoError if the input data format is invalid or key creation fails
    static func createPublicKey(certificateData data: Data) throws -> SecKey {
        guard let certData = SecCertificateCreateWithData(nil, data as CFData) else {
            throw CryptoError.algorithmsFailed(
                reason: .createKeyFailed(data: data, reason: "The data is not a valid DER-encoded X.509 certificate"))
        }
        
        // Get public key from certData
        let copyKey: (SecCertificate) -> SecKey?
        copyKey = SecCertificateCopyKey

        guard let key = copyKey(certData) else {
            throw CryptoError.algorithmsFailed(
                reason: .createKeyFailed(data: data, reason: "Cannot copy public key from certificate"))
        }
        return key
    }
}

extension String {
    /// Returns a base64 encoded string with markers stripped.
    ///
    /// - Returns: The base64 encoded string with markers stripped.
    /// - Throws: CryptoError if the input string format is invalid
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
    
    /// Returns the corresponding byte value for the ASN.1 type.
    var byte: UInt8 {
        switch self {
        case .sequence: return 0x30
        case .integer: return 0x02
        case .bitString: return 0x03
        case .uncompressedIndicator: return 0x04
        }
    }
}
