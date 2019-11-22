//
//  ImageManager.swift
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

typealias ImageSettingResult = Result<UIImage, LineSDKError>

class ImageManager {

    typealias TaskToken = UInt
    private var currentToken: TaskToken = 0
    func nextToken() -> TaskToken {
        if currentToken < TaskToken.max - 1 {
            currentToken += 1
        } else {
            currentToken = 1
        }
        return currentToken
    }

    static let shared = ImageManager()

    let downloader = ImageDownloader()
    let cache: NSCache<NSURL, UIImage>

    private init() {
        cache = NSCache()
        cache.countLimit = 500
    }

    func getImage(
        _ url: URL,
        taskToken: TaskToken,
        callbackQueue: CallbackQueue = .currentMainOrAsync,
        completion: @escaping (ImageSettingResult, TaskToken) -> Void)
    {
        getImage(url, callbackQueue: callbackQueue) { completion($0, taskToken) }
    }

    func getImage(
        _ url: URL,
        callbackQueue: CallbackQueue = .currentMainOrAsync,
        completion: ((ImageSettingResult) -> Void)? = nil)
    {
        let nsURL = url as NSURL
        if let image = cache.object(forKey: nsURL) {
            if let completion = completion {
                callbackQueue.execute { completion(.success(image)) }
            }
            return
        }

        downloader.download(url: url, callbackQueue: callbackQueue) { result in

            let callbackResult: ImageSettingResult
            switch result {
            case .success(let image):
                self.cache.setObject(image, forKey: nsURL)
                callbackResult = .success(image)
            case .failure(let error):
                callbackResult = .failure(error)
            }

            if let completion = completion {
                callbackQueue.execute { completion(callbackResult) }
            }
        }
    }

    func purgeCache() {
        cache.removeAllObjects()
    }

}
