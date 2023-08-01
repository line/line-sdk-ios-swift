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
    
    init(parameters: Parameters) {
        self.parameters = parameters
    }
    
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
            
            var allowedCharacterSet = CharacterSet.urlQueryAllowed
            allowedCharacterSet.remove(charactersIn: "!*'();:@&=+$,/?%#[]")
            
            let percentEncodedQuery = (components.percentEncodedQuery.map { $0 + "&" } ?? "") +
                                      query(parameters, allowed: allowedCharacterSet)
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


private func query(_ parameters: Parameters, allowed: CharacterSet = .urlQueryAllowed) -> String {
    return parameters
        .reduce([]) {
            (result, kvp) in
            result + queryComponents(fromKey: kvp.key, value: kvp.value, allowed: allowed)
        }
        .map { "\($0)=\($1)" }
        .joined(separator: "&")
}

private func queryComponents(
    fromKey key: String,
    value: Any,
    allowed: CharacterSet = .urlQueryAllowed) -> [(String, String)]
{
    var components: [(String, String)] = []

    if let dictionary = value as? [String: Any] {
        for (nestedKey, value) in dictionary {
            components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value, allowed: allowed)
        }
    } else if let array = value as? [Any] {
        for value in array {
            components += queryComponents(fromKey: "\(key)[]", value: value, allowed: allowed)
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
        components.append((escape(key), escape("\(value)", allowed: allowed)))
    }
    
    return components
}

// Reserved characters defined by RFC 3986
// Reference: https://www.ietf.org/rfc/rfc3986.txt
private func escape(_ string: String, allowed: CharacterSet = .urlQueryAllowed) -> String {
    let generalDelimitersToEncode = ":#[]@"
    let subDelimitersToEncode = "!$&'()*+,;="
    
    var allowedCharacterSet = allowed
    allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

    return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
}

extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}
