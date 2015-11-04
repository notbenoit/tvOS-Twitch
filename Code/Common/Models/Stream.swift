// Copyright (c) 2015 Benoit Layer
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

import Foundation
import ReactiveCocoa
import ObjectMapper

struct Stream {
	var id: Int!
	var gameNameString: String!
	var viewers: Int!
	var averageFPS: Double!
	var delay: Int!
	var videoHeight: Int!
	var isPlaylist: Bool!
	var channel: Channel!
	var preview: Preview!
}

extension Stream: CustomStringConvertible {
	internal var description: String {
		return ""
	}
}

extension Stream: Mappable {
	
	init?(_ map: Map) {
	}
	
	mutating func mapping(map: Map) {
		id     <- map["_id"]
		gameNameString <- map["game"]
		viewers <- map["viewers"]
		averageFPS <- map["average_fps"]
		delay <- map["delay"]
		videoHeight <- map["videoHeight"]
		isPlaylist <- map["is_playlist"]
		channel <- map["channel"]
		preview <- map["preview"]
	}
}