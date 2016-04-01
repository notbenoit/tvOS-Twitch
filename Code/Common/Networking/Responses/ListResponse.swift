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

protocol ListResponseType: JSONParsing {
	associatedtype T: JSONParsing
	var objects: [T] { get }
	var count: Int { get }
	static var rootPath: String { get }
	
	init(objects: [T], count: Int)
}

extension ListResponseType {
	static func parse(json: JSON) throws -> Self {
		return try Self(
			objects: json[self.rootPath].array.map(^),
			count: json["_total"]^)
	}
}

struct TopGamesResponse: ListResponseType {
	let objects: [TopGame]
	let count: Int
	
	static let rootPath: String = "top"
}

struct StreamsResponse: ListResponseType {
	let objects: [Stream]
	let count: Int
	
	static let rootPath: String = "streams"
}
