//
//  LineSDKFlexIconComponent.swift
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
public class LineSDKFlexIconComponent: LineSDKFlexMessageComponent {
    public let url: URL
    public var margin: LineSDKFlexMessageComponentMargin = .none
    public var size: LineSDKFlexMessageComponentSize = .none
    public var aspectRatio: LineSDKFlexMessageComponentAspectRatio = .none
    
    public init?(iconURL: URL) {
        do {
            _ = try FlexIconComponent(url: iconURL)
            self.url = iconURL
        } catch {
            Log.assertionFailure("An error happened: \(error)")
            return nil
        }
    }
    
    convenience init(_ value: FlexIconComponent) {
        self.init(iconURL: value.url)!
        margin = .init(value.margin)
        size = .init(value.size)
        aspectRatio = .init(value.aspectRatio)
    }
    
    override var unwrapped: FlexMessageComponent {
        var component = try! FlexIconComponent(url: url)
        component.margin = margin.unwrapped
        component.size = size.unwrapped
        component.aspectRatio = aspectRatio.unwrapped
        return .icon(component)
    }
}
