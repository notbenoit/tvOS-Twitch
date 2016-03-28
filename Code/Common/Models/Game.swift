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
import ReactiveCocoa

struct Game {
	let gameNameString: String
	let id: Int
	let giantBombId: Int
	let box: Preview
	let logo: Preview
	let popularity: Int?
}

extension Game: CustomStringConvertible {
	internal var description: String {
		return gameNameString
	}
}

// MARK: JSONParsing

extension Game: JSONParsing {
	static func parse(json: JSON) throws -> Game {
		return try Game(
			gameNameString: json["name"]^,
			id: json["_id"]^,
			giantBombId: json["giantbomb_id"]^,
			box: json["box"]^,
			logo: json["logo"]^,
			popularity: json["popularity"].optional.map(^))
	}
}

// MARK: Hashable

extension Game: Hashable {
	var hashValue: Int {
		return id
	}
}

// MARK: Equatable

extension Game: Equatable { }
func ==(lhs: Game, rhs: Game) -> Bool {
	return lhs.hashValue == rhs.hashValue
}