//
//  FlexBoxComponent.swift
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

public struct FlexBoxComponent: Codable, FlexMessageComponentTypeCompatible {
    let type: FlexMessageComponentType = .box
    
    public let layout: FlexMessageComponent.Layout
    public var contents: [FlexMessageComponent]
    
    public var flex: FlexMessageComponent.Ratio?
    public var spacing: FlexMessageComponent.Spacing?
    public var margin: FlexMessageComponent.Margin?
    public var action: MessageAction?
    
    public init(layout: FlexMessageComponent.Layout, contents: [FlexMessageComponent] = []) {
        self.layout = layout
        self.contents = contents
    }
    
    mutating func addComponent(_ component: FlexMessageComponent) {
        contents.append(component)
    }
    
    mutating func removeFisrtComponent(
        where condition: (FlexMessageComponent) throws -> Bool) rethrows -> FlexMessageComponent?
    {
        guard let index = try contents.index(where: condition) else {
            return nil
        }
        return contents.remove(at: index)
    }
}

extension FlexBoxComponent {
    public var component: FlexMessageComponent { return .box(self) }
}
