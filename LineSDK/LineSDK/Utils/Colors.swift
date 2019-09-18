//
//  Colors.swift
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

// Backward compatible for compilers shipped with Xcode 10.
// We can remove this later when dropping Xcode 10 support.
#if compiler(>=5.1)
#else
extension UIColor {
    static let label = UIColor.black
    static let secondaryLabel = UIColor(hex8: 0x3c3c4399)
    static let tertiaryLabel = UIColor(hex8: 0x3c3c434c)
    static let quaternaryLabel = UIColor(hex8: 0x3c3c432d)
    static let systemFill = UIColor(hex8: 0x78788033)
    static let secondarySystemFill = UIColor(hex8: 0x78788028)
    static let tertiarySystemFill = UIColor(hex8: 0x7676801e)
    static let quaternarySystemFill = UIColor(hex8: 0x74748014)
    static let placeholderText = UIColor(hex8: 0x3c3c434c)
    static let systemBackground = UIColor(hex8: 0xffffffff)
    static let secondarySystemBackground = UIColor(hex8: 0xf2f2f7ff)
    static let tertiarySystemBackground = UIColor(hex8: 0xffffffff)
    static let systemGroupedBackground = UIColor(hex8: 0xf2f2f7ff)
    static let secondarySystemGroupedBackground = UIColor(hex8: 0xffffffff)
    static let tertiarySystemGroupedBackground = UIColor(hex8: 0xf2f2f7ff)
    static let separator = UIColor(hex8: 0x3c3c4349)
    static let opaqueSeparator = UIColor(hex8: 0xc6c6c8ff)
    static let link = UIColor(hex8: 0x007affff)
    static let systemGray = UIColor(hex8: 0x8e8e93ff)
    static let systemGray2 = UIColor(hex8: 0xaeaeb2ff)
    static let systemGray3 = UIColor(hex8: 0xc7c7ccff)
    static let systemGray4 = UIColor(hex8: 0xd1d1d6ff)
    static let systemGray5 = UIColor(hex8: 0xe5e5eaff)
    static let systemGray6 = UIColor(hex8: 0xf2f2f7ff)
}
#endif

extension UIColor {
    static var LineSDKLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }

    static var LineSDKSecondaryLabel : UIColor {
        if #available(iOS 13.0, *) {
            return .secondaryLabel
        } else {
            return .systemGray
        }
    }

    static var LineSDKSystemBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }

    static var LineSDKSecondarySystemBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .secondarySystemBackground
        } else {
            return .white
        }
    }

    static var LineSDKTertiarySystemBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .tertiarySystemBackground
        } else {
            return .white
        }
    }

    static var LineSDKPanelBorder: UIColor {
        return compatibleColor(light: .init(hex6: 0xE6E7EA), dark: .init(hex6: 0x1D1D1E))
    }

    static var LineSDKPanelBackground: UIColor {
        return compatibleColor(light: .init(hex6: 0xF7F8FA), dark: .init(hex6: 0x1C1C1E))
    }

    static func compatibleColor(
        light: @autoclosure @escaping () -> UIColor,
        dark: @autoclosure @escaping () -> UIColor
    ) -> UIColor {
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            return UIColor { trait in
                trait.userInterfaceStyle == .light ? light() : dark()
            }
        } else {
            return light()
        }
        #else
        return light()
        #endif
    }

    static func compatibleColor(light: UInt32, dark: UInt32) -> UIColor {
        return compatibleColor(light: .init(hex6: light), dark: .init(hex6: dark))
    }
}
