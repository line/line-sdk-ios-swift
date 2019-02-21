//
//  FlexCarouselContainer.swift
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

/// LINE internal use only.
/// Represents a container that contains multiple bubble containers. The bubbles will be shown in order by
/// scrolling horizontally.
///
public struct FlexCarouselContainer: Codable, FlexMessageContainerTypeCompatible {
    let type = FlexMessageContainerType.carousel
    
    /// Array of `FlexBubbleContainer`s. You could set at most 10 bubble container in this carousel container.
    /// Line SDK does not check the elements count in a container. However, it would cause an API response error
    /// if more bubbles contained in the container.
    public var contents: [FlexBubbleContainer]
    
    /// Creates a carousel container with given information
    ///
    /// - Parameter contents: Bubble containers which consist this carousel container.
    public init(contents: [FlexBubbleContainer] = []) {
        self.contents = contents
    }
    
    /// Appends a bubble to current `contents`.
    ///
    /// - Parameter value: Bubble to append.
    public mutating func addBubble(_ value: FlexBubbleContainer) {
        contents.append(value)
    }
    
    /// Removes the first bubble from `contents` which meets the given `condition`.
    ///
    /// - Parameter condition: A closure that takes an element as its argument and returns a `Bool` value that
    ///                        indicates whether the passed element represents a match.
    /// - Returns: The element which was removed, or `nil` if matched element not found.
    /// - Throws: Rethrows the `condition` block error.
    public mutating func removeFirstBubble(
        where condition: (FlexBubbleContainer) throws -> Bool) rethrows -> FlexBubbleContainer?
    {
        #if swift(>=5.0)
        guard let index = try contents.firstIndex(where: condition) else {
            return nil
        }
        #else
        guard let index = try contents.index(where: condition) else {
            return nil
        }
        #endif

        
        return contents.remove(at: index)
    }
    
}

extension FlexCarouselContainer: FlexMessageConvertible {
    /// Returns a converted `FlexMessageContainer` which wraps this `FlexCarouselContainer`.
    public var container: FlexMessageContainer { return .carousel(self) }
}
