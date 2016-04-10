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
import JSONParsing

struct Stream {
	let id: Int
	let gameNameString: String?
	let viewers: Int
	let averageFPS: Double
	let delay: Int
	let videoHeight: Int
	let isPlaylist: Bool
	let channel: Channel
	let preview: Preview
}

extension Stream: CustomStringConvertible {
	internal var description: String {
		return ""
	}
}

// MARK: JSONParsing

extension Stream: JSONParsing {
	static func parse(json: JSON) throws -> Stream {
		return try Stream(
			id: json["_id"]^,
			gameNameString: json["game"].optional.map(^),
			viewers: json["viewers"]^,
			averageFPS: json["average_fps"]^,
			delay: json["delay"]^,
			videoHeight: json["video_height"]^,
			isPlaylist: json["is_playlist"]^,
			channel: json["channel"]^,
			preview: json["preview"]^)
	}
}

// MARK: Hashable
extension Stream: Hashable {
	var hashValue: Int { return id.hashValue }
}

// MARK: Equatable

extension Stream: Equatable { }
func == (lhs: Stream, rhs: Stream) -> Bool {
	return lhs.id == rhs.id
}

// MARK: Comparable
extension Stream: Comparable { }
func < (lhs: Stream, rhs: Stream) -> Bool {
	return lhs.viewers < rhs.viewers
}

func <= (lhs: Stream, rhs: Stream) -> Bool {
	return lhs.viewers <= rhs.viewers
}

func > (lhs: Stream, rhs: Stream) -> Bool {
	return lhs.viewers > rhs.viewers
}

func >= (lhs: Stream, rhs: Stream) -> Bool {
	return lhs.viewers >= rhs.viewers
}

