//
//  ImageViewExtension.swift
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

extension UIImageView {
    func setImage(
        _ url: URL?,
        placeholder: UIImage? = nil,
        verifier: ((ImageManager.DownloadTaskToken) -> Bool)? = nil,
        completion: ((ImageSettingResult) -> Void)? = nil) -> ImageManager.DownloadTaskToken?
    {
        image = placeholder
        guard let url = url else {
            completion?(.success(placeholder ?? UIImage()))
            return nil
        }
        let token = ImageManager.shared.nextToken(url)
        ImageManager.shared.getImage(url) { result in
            guard let image = try? result.get() else { // Error case
                completion?(result)
                return
            }

            guard let token = token else { // No download task token. Loaded from cache.
                self.image = image
                completion?(result)
                return
            }

            guard let verifier = verifier else { // No verifier, just ignore download/reuse order.
                self.image = image
                completion?(result)
                return
            }

            if verifier(token) { // Only set image when it is the one initializing the request
                self.image = image
                completion?(result)
            } else {
                completion?(.failure(LineSDKError.generalError(reason: .notOriginalTask(token: token))))
            }
        }
        return token
    }
}
