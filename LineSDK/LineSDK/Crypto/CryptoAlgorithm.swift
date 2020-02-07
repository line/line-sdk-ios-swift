//
//  CryptoAlgorithm.swift
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
import Security

typealias CryptoDigest = (
    _ data: UnsafeRawPointer?,
    _ length: CC_LONG,
    _ md: UnsafeMutablePointer<UInt8>?) -> UnsafeMutablePointer<UInt8>?

/// Represents an algorithm used in cryptography.
protocol CryptoAlgorithm {
    var digestAlgorithm: DigestAlgorithm { get }
    var length: CC_LONG { get }
    var signatureAlgorithm: SecKeyAlgorithm { get }
    var encryptionAlgorithm: SecKeyAlgorithm { get }
    var digest: CryptoDigest { get }
    // Some algorithms require a different format for signature data. This is an injection point for it.
    func convertSignatureData(_ data: Data) throws -> Data
}

extension CryptoAlgorithm {
    var length: CC_LONG { return digestAlgorithm.length }
    var digest: CryptoDigest { return digestAlgorithm.digest }
    func convertSignatureData(_ data: Data) throws -> Data { return data }
}

extension Data {

    /// Calculate the digest with a given algorithm.
    ///
    /// - Parameter algorithm: The algorithm be used. It should provide a digest hash method at least.
    /// - Returns: The digest data.
    func digest(using algorithm: CryptoAlgorithm) -> Data {
        return digest(using: algorithm.digestAlgorithm)
    }

    func digest(using algorithm: DigestAlgorithm) -> Data {
        var hash = [UInt8](repeating: 0, count: Int(algorithm.length))
        #if swift(>=5.0)
        withUnsafeBytes { _ = algorithm.digest($0.baseAddress, CC_LONG(count), &hash) }
        return Data(hash)
        #else
        withUnsafeBytes { _ = algorithm.digest($0, CC_LONG(count), &hash) }
        return Data(bytes: hash)
        #endif
    }

    static func randomData(bytesCount: Int) -> Data {
        var bytes = [UInt8](repeating: 0, count: bytesCount)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status != errSecSuccess {
            bytes = bytes.map { _ in UInt8.random(in: UInt8.min...UInt8.max) }
        }
        #if swift(>=5.0)
        return Data(bytes)
        #else
        return Data(bytes: bytes)
        #endif
    }
}

enum DigestAlgorithm {
    case sha1, sha224, sha256, sha384, sha512

    var length: CC_LONG {
        switch self {
        case .sha1: return CC_LONG(CC_SHA1_DIGEST_LENGTH)
        case .sha224: return CC_LONG(CC_SHA224_DIGEST_LENGTH)
        case .sha256: return CC_LONG(CC_SHA256_DIGEST_LENGTH)
        case .sha384: return CC_LONG(CC_SHA384_DIGEST_LENGTH)
        case .sha512: return CC_LONG(CC_SHA512_DIGEST_LENGTH)
        }
    }

    var digest: CryptoDigest {
        switch self {
        case .sha1:   return CC_SHA1
        case .sha224: return CC_SHA224
        case .sha256: return CC_SHA256
        case .sha384: return CC_SHA384
        case .sha512: return CC_SHA512
        }
    }
}
