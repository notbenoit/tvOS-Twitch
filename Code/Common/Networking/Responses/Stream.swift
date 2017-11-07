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

struct Stream: Codable {
	let averageFPS: Double
	let channel: Channel
	let delay: Int
	let gameName: String?
	let id: Int
	let isPlaylist: Bool
	let preview: Preview
	let videoHeight: Int
	let viewers: Int

	enum CodingKeys: String, CodingKey {
		case averageFPS = "average_fps"
		case channel
		case delay
		case gameName = "game"
		case id = "_id"
		case isPlaylist = "is_playlist"
		case preview
		case videoHeight = "video_height"
		case viewers
	}

}

extension Stream: CustomStringConvertible {
	internal var description: String {
		return ""
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

