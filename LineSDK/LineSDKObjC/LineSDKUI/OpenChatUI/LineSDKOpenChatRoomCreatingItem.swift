//
//  LineSDKOpenChatRoomCreatingItem.swift
//
//  Copyright (c) 2016-present, LY Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LY Corporation.
//
//  As with any software that integrates with the LY Corporation platform, your use of this software
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

@objcMembers
public class LineSDKOpenChatRoomCreatingItem: NSObject {
    let _value: OpenChatRoomCreatingItem
    init(_ value: OpenChatRoomCreatingItem) { _value = value }
    
    public var name: String { return _value.name }
    public var roomDescription: String { return _value.roomDescription }
    public var creatorDisplayName: String { return _value.creatorDisplayName }
    public var category: Int { return _value.category }
    public var allowSearch: Bool { return _value.allowSearch }
    
    public init(
        name: String,
        roomDescription: String,
        creatorDisplayName: String,
        category: Int,
        allowSearch: Bool
    )
    {
        _value = OpenChatRoomCreatingItem(
            name: name,
            roomDescription: roomDescription,
            creatorDisplayName: creatorDisplayName,
            category: category,
            allowSearch: allowSearch
        )
    }
}
