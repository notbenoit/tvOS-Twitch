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
import ReactiveCocoa
import JSONParsing

struct TopGame {
	let game: Game
	let viewers: Int
	let channels: Int
}

extension TopGame: CustomStringConvertible {
	internal var description: String {
		return game.gameNameString + "\nViewers =>" + String(viewers)
	}
}

// MARK: JSONParsing

extension TopGame: JSONParsing {
	static func parse(json: JSON) throws -> TopGame {
		return try TopGame(
			game: json["game"]^,
			viewers: json["viewers"]^,
			channels: json["channels"]^)
	}
}

// MARK: Hashable

extension TopGame: Hashable {
	var hashValue: Int {
		return game.hashValue
	}
}

// MARK: Equatable

extension TopGame: Equatable { }
func ==(lhs: TopGame, rhs: TopGame) -> Bool {
	return lhs.hashValue == rhs.hashValue
}

// MARK: Comparable

extension TopGame: Comparable { }
func <(lhs: TopGame, rhs: TopGame) -> Bool {
	return lhs.viewers < rhs.viewers
}

func <=(lhs: TopGame, rhs: TopGame) -> Bool {
	return lhs.viewers <= rhs.viewers
}

func >=(lhs: TopGame, rhs: TopGame) -> Bool {
	return lhs.viewers >= rhs.viewers
}

func >(lhs: TopGame, rhs: TopGame) -> Bool {
	return lhs.viewers > rhs.viewers
}
