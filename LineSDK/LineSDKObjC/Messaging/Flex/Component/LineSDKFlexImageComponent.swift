//
//  LineSDKFlexImageComponent.swift
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
public class LineSDKFlexImageComponent: LineSDKFlexMessageComponent {
    
    public let url: URL
    public var flex: NSNumber?
    public var margin: LineSDKFlexMessageComponentMargin = .none
    public var alignment: LineSDKFlexMessageComponentAlignment = .none
    public var gravity: LineSDKFlexMessageComponentGravity = .none
    public var size: LineSDKFlexMessageComponentSize = .none
    public var aspectRatio: LineSDKFlexMessageComponentAspectRatio = .none
    public var aspectMode: LineSDKFlexMessageComponentAspectMode = .none
    public var backgroundColor: LineSDKHexColor?
    
    public init?(imageURL: URL) {
        do {
            _ = try FlexImageComponent(url: imageURL)
            self.url = imageURL
        } catch {
            Log.assertionFailure("An error happened: \(error)")
            return nil
        }
    }
    
    convenience init(_ value: FlexImageComponent) {
        self.init(imageURL: value.url)!
        flex = value.flex.map { .init(value: $0) }
        margin = .init(value.margin)
        alignment = .init(value.alignment)
        gravity = .init(value.gravity)
        size = .init(value.size)
        aspectRatio = .init(value.aspectRatio)
        aspectMode = .init(value.aspectMode)
        backgroundColor = value.backgroundColor.map { .init($0) }
    }
    
    override var unwrapped: FlexMessageComponent {
        return .image(component)
    }
    
    var component: FlexImageComponent {
        var component = try! FlexImageComponent(url: url)
        component.flex = flex?.uintValue
        component.margin = margin.unwrapped
        component.alignment = alignment.unwrapped
        component.gravity = gravity.unwrapped
        component.size = size.unwrapped
        component.aspectRatio = aspectRatio.unwrapped
        component.aspectMode = aspectMode.unwrapped
        component.backgroundColor = backgroundColor?.unwrapped
        return component
    }
}
