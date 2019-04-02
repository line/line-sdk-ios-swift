//
//  ImageDownloader.swift
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

import UIKit

class ImageDownloader {
    let session: URLSession

    init() {
        session = URLSession(configuration: .default)
    }

    func download(
        url: URL,
        callbackQueue: CallbackQueue = .asyncMain,
        completion: @escaping (ImageSettingResult) -> Void)
    {
        session.dataTask(with: url) { (data, response, error) in

            let callback: ((Result<UIImage, LineSDKError>) -> Void) = { result in
                callbackQueue.execute { completion(result) }
            }

            guard let response = response as? HTTPURLResponse else {
                callback(.failure(.responseFailed(reason: .nonHTTPURLResponse)))
                return
            }

            guard response.statusCode < 300 && response.statusCode >= 200 else {
                callback(.failure(.responseFailed(reason: .nonHTTPURLResponse)))
                return
            }

            if let data = data {
                if let image = UIImage(data: data) {
                    callback(.success(image))
                } else {
                    callback(.failure(.responseFailed(reason: .dataParsingFailed(UIImage.self, data, nil))))
                }
            } else {
                if let error = error {
                    callback(.failure(.responseFailed(reason: .URLSessionError(error))))
                } else {
                    callback(.failure(.responseFailed(reason: .nonHTTPURLResponse)))
                }
            }
        }.resume()
    }
}
