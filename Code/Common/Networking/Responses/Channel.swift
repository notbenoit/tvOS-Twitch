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

struct Channel {
	let id: Int
	let mature: Bool?
	let status: String?
	let displayName: String
	let gameName: String
	let channelName: String
}

extension Channel: CustomStringConvertible {
	internal var description: String {
		return channelName + " on " + gameName
	}
}

extension Channel: JSONParsing {
	static func parse(json: JSON) throws -> Channel {
		return try Channel(
			id: json["_id"]^,
			mature: json["mature"].optional.map(^),
			status: json["status"].optional.map(^),
			displayName: json["display_name"]^,
			gameName: json["game"]^,
			channelName: json["name"]^)
	}
}

extension Channel: Hashable {
	var hashValue: Int {
		return id
	}
}

extension Channel: Equatable { }
func == (lhs: Channel, rhs: Channel) -> Bool {
	return lhs.id == rhs.id
}