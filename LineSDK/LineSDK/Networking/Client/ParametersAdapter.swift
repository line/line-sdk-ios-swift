//
//  ParametersAdapter.swift
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

struct URLQueryEncoder: RequestAdapter {
    let parameters: Parameters
    func adapted(_ request: URLRequest) throws -> URLRequest {
        
        guard let url = request.url else {
            throw LineSDKError.requestFailed(reason: .missingURL)
        }
        
        var request = request
        let finalURL = encoded(for: url)
        request.url = finalURL
        
        return request
    }
    
    func encoded(for url: URL) -> URL {
        if var components = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            let percentEncodedQuery = (components.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
            components.percentEncodedQuery = percentEncodedQuery
            return components.url ?? url
        }
        return url
    }
}

struct JSONParameterEncoder: RequestAdapter {
    let parameters: Parameters
    func adapted(_ request: URLRequest) throws -> URLRequest {
        
        var request = request
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = data
        } catch {
            throw LineSDKError.requestFailed(reason: .jsonEncodingFailed(error))
        }
        
        return request
    }
}

struct FormUrlEncodedParameterEncoder: RequestAdapter {
    let parameters: Parameters
    func adapted(_ request: URLRequest) throws -> URLRequest {
        var request = request
        request.httpBody = query(parameters).data(using: .utf8, allowLossyConversion: false)
        return request
    }
}


private func query(_ parameters: Parameters) -> String {
    return parameters
        .reduce([]) {
            (result, kvp) in
            result + queryComponents(fromKey: kvp.key, value: kvp.value)
        }
        .map { "\($0)=\($1)" }
        .joined(separator: "&")
}

private func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
    var components: [(String, String)] = []

    if let dictionary = value as? [String: Any] {
        for (nestedKey, value) in dictionary {
            components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
        }
    } else if let array = value as? [Any] {
        for value in array {
            components += queryComponents(fromKey: "\(key)[]", value: value)
        }
    } else if let value = value as? NSNumber {
        if value.isBool {
            components.append((escape(key), escape(value.boolValue ? "true": "false")))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
    } else if let bool = value as? Bool {
        components.append((escape(key), escape(bool ? "true": "false")))
    } else {
        components.append((escape(key), escape("\(value)")))
    }
    
    return components
}

// Reserved characters defined by RFC 3986
// Reference: https://www.ietf.org/rfc/rfc3986.txt
private func escape(_ string: String) -> String {
    let generalDelimitersToEncode = ":#[]@"
    let subDelimitersToEncode = "!$&'()*+,;="
    
    var allowedCharacterSet = CharacterSet.urlQueryAllowed
    allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
    
    var escaped = ""

    // Crashes due to internal bug in iOS 7 ~ iOS 8.2.
    // References:
    //   - https://github.com/Alamofire/Alamofire/issues/206
    //   - https://github.com/AFNetworking/AFNetworking/issues/3028
    if #available(iOS 8.3, *) {
        escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    } else {
        let batchSize = 50
        var index = string.startIndex
        
        while index != string.endIndex {
            let startIndex = index
            let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
            let range = startIndex..<endIndex
            
            let substring = string[range]
            
            escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? String(substring)
            
            index = endIndex
        }
    }
    
    return escaped
}

extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}
