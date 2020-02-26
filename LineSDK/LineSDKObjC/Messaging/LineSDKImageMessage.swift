//
//  LineSDKImageMessage.swift
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

#if !LineSDKCocoaPods && !LineSDKBinary
import LineSDK
#endif

@objcMembers
public class LineSDKImageMessage: LineSDKMessage {
    public let originalContentURL: URL
    public let previewImageURL: URL
    public var animated: Bool
    public var fileExtension: String?
    public var sender: LineSDKMessageSender?
    
    convenience init(_ value: ImageMessage) {
        self.init(
            originalContentURL: value.originalContentURL,
            previewImageURL: value.previewImageURL,
            animated: value.animated ?? false,
            fileExtension: value.fileExtension,
            sender: value.sender.map { .init($0) })!
    }
    
    public convenience init?(originalContentURL: URL, previewImageURL: URL) {
        self.init(
            originalContentURL: originalContentURL,
            previewImageURL: previewImageURL,
            animated: false,
            fileExtension: nil,
            sender: nil)
    }
    
    public init?(
        originalContentURL: URL,
        previewImageURL: URL,
        animated: Bool,
        fileExtension: String?,
        sender: LineSDKMessageSender?)
    {
        do {
            _ = try ImageMessage(originalContentURL: originalContentURL, previewImageURL: previewImageURL)
            self.originalContentURL = originalContentURL
            self.previewImageURL = previewImageURL
            self.animated = animated
            self.fileExtension = fileExtension
            self.sender = sender
        } catch {
            Log.assertionFailure("An error happened: \(error)")
            return nil
        }
    }
    
    override var unwrapped: Message {
        return .image(try! .init(
            originalContentURL: originalContentURL,
            previewImageURL: previewImageURL,
            animated: animated,
            fileExtension: fileExtension,
            sender: sender?.unwrapped
            ))
    }
}
