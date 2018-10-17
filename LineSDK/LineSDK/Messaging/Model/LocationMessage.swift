//
//  LocationMessage.swift
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
/// Represents a message containing an address and location.
public struct LocationMessage: Codable, MessageTypeCompatible {
    
    /// Represents a location latitude or longitude degrees.
    public typealias LocationDegrees = Double
    
    let type = MessageType.location
    
    /// Title name of the location.
    public var title: String
    
    /// Address of the location.
    public var address: String
    
    /// Latitude value of the location.
    public var latitude: LocationDegrees
    
    /// Longitude value of the location.
    public var longitude: LocationDegrees
    
    /// Creates a location message with given information.
    ///
    /// - Parameters:
    ///   - title: Title name of the location.
    ///   - address: Address of the location.
    ///   - latitude: Latitude value of the location.
    ///   - longitude: Longitude value of the location.
    public init(title: String, address: String, latitude: LocationDegrees, longitude: LocationDegrees) {
        self.title = title
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension LocationMessage: MessageConvertible {
    /// Returns a converted `Message` which wraps this `LocationMessage`.
    public var message: Message { return .location(self) }
}
