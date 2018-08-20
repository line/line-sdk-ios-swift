//
//  FlexTextComponent.swift
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

public struct FlexTextComponent: Codable, FlexMessageComponentTypeCompatible {
    let type = FlexMessageComponentType.text
    
    public var text: String
    public var flex: UInt?
    public var margin: FlexMessageComponent.Margin?
    public var size: FlexMessageComponent.Size?
    public var align: FlexMessageComponent.Align?
    public var gravity: FlexMessageComponent.Gravity?
    public var wrap: Bool?
    public var maxLines: UInt?
    public var weight: FlexMessageComponent.Weight?
    public var color: UIColor?
    public var action: MessageAction?
    
    public init(text: String) {
        self.text = text
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        flex = try container.decodeIfPresent(UInt.self, forKey: .flex)
        margin = try container.decodeIfPresent(FlexMessageComponent.Margin.self, forKey: .margin)
        size = try container.decodeIfPresent(FlexMessageComponent.Size.self, forKey: .size)
        align = try container.decodeIfPresent(FlexMessageComponent.Align.self, forKey: .align)
        gravity = try container.decodeIfPresent(FlexMessageComponent.Gravity.self, forKey: .gravity)
        wrap = try container.decodeIfPresent(Bool.self, forKey: .wrap)
        maxLines = try container.decodeIfPresent(UInt.self, forKey: .maxLines)
        weight = try container.decodeIfPresent(FlexMessageComponent.Weight.self, forKey: .weight)
        
        if let colorString = try container.decodeIfPresent(String.self, forKey: .color) {
            color = UIColor(rgb: colorString)
        } else {
            color = nil
        }
        
        action = try container.decodeIfPresent(MessageAction.self, forKey: .size)
    }
}
