//
//  FlexBubbleContainer.swift
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

public struct FlexBubbleContainer: Codable, FlexMessageContainerTypeCompatible {
    
    public struct Style: Codable {
        var header: FlexBlockStyle?
        var hero: FlexBlockStyle?
        var body: FlexBlockStyle?
        var footer: FlexBlockStyle?
    }
    
    let type = FlexMessageContainerType.bubble
    
    public var header: FlexBoxComponent?
    public var hero: FlexImageComponent?
    public var body: FlexBoxComponent?
    public var footer: FlexBoxComponent?
    public var styles: Style?
    
    public init(
        header: FlexBoxComponent? = nil,
        hero: FlexImageComponent? = nil,
        body: FlexBoxComponent? = nil,
        footer: FlexBoxComponent? = nil,
        styles: Style? = nil)
    {
        self.header = header
        self.hero = hero
        self.body = body
        self.footer = footer
        self.styles = styles
    }
}

extension FlexBubbleContainer: FlexMessageConvertible {
    public var container: FlexMessageContainer { return .bubble(self) }
}

extension Message {
    public static func flexBubbleMessage(
        altText: String,
        container: FlexBubbleContainer) -> Message
    {
        return container.messageWithAltText(altText)
    }
}
