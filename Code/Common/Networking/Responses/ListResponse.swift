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
import ReactiveSwift
import Result

// MARK: - Links
struct Links: Codable {
	let current: String?
	let next: String?

	enum CodingKeys: String, CodingKey {
		case current = "self"
		case next
	}
}

// MARK: - List Response
protocol ListResponseType: Decodable {
	associatedtype Element: Decodable
	var objects: [Element] { get }
	var count: Int { get }
	var links: Links { get }

	static var rootPath: String { get }

	init(objects: [Element], count: Int, links: Links)
}

enum ListResponseKeys: CodingKey {
	case root(String)
	case total
	case links

	var intValue: Int? { return nil }

	var stringValue: String {
		switch self {
		case let .root(value):
			return value
		case .total:
			return "_total"
		case .links:
			return "_links"
		}
	}

	init?(intValue: Int) { return nil }

	init?(stringValue: String) {
		switch stringValue {
		case "_total":
			self = .total
		case "_links":
			self = .links
		default:
			self = .root(stringValue)
		}
	}
}

extension ListResponseType {

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: ListResponseKeys.self)
		try self.init(
			objects: container.decode([Element].self, forKey: .root(Self.rootPath)),
			count: container.decode(Int.self, forKey: .total),
			links: container.decode(Links.self, forKey: .links))
	}

}

struct TopGamesResponse: ListResponseType {
	let objects: [TopGame]
	let count: Int
	let links: Links

	static let rootPath: String = "top"
}

struct StreamsResponse: ListResponseType {
	let objects: [Stream]
	let count: Int
	let links: Links

	static let rootPath: String = "streams"
}

struct GamesResponse: ListResponseType {
	let objects: [Game]
	let count: Int
	let links: Links

	static let rootPath: String = "streams"
}

final class Paginator<Response: ListResponseType> {
	let objects = MutableProperty<[Response.Element]>([])
	let loadURLAction: Action<String, Response, AnyError>
	let loadRouteAction: Action<TwitchRouter, Response, AnyError>
	let initialRoute: TwitchRouter

	let lastResponse = MutableProperty<Response?>(nil)
	let totalCount = MutableProperty<Int?>(nil)
	let allLoaded = MutableProperty<Bool>(false)

	let nextLink = MutableProperty<String?>(nil)
	var currentLink = MutableProperty<String?>(nil)

	let loadingState: SignalProducer<LoadingState<AnyError>, NoError>

	init(_ initialRoute: TwitchRouter) {
		self.initialRoute = initialRoute
		loadURLAction = Action(execute: TwitchAPIClient.sharedInstance.request)
		loadRouteAction = Action(execute: TwitchAPIClient.sharedInstance.request)
		loadingState = SignalProducer([loadURLAction.loadingState, loadRouteAction.loadingState]).flatten(.merge)

		allLoaded <~ SignalProducer
			.combineLatest(totalCount.producer.skipNil(), objects.producer)
			.map { $0 <= $1.count }

		let anyOutput = Signal.merge(loadRouteAction.values, loadURLAction.values)
		lastResponse <~ anyOutput
		nextLink <~ anyOutput.map { $0.links.next }
		currentLink <~ anyOutput.map { $0.links.current }

		loadRouteAction.values.observeValues { [weak self] in
			self?.objects.value = $0.objects
		}

		loadURLAction.values.observeValues { [weak self] in
			self?.objects.value += $0.objects
		}
		
		loadFirst()
	}

	func loadFirst() {
		objects.value = []
		lastResponse.value = nil
		nextLink.value = nil
		currentLink.value = nil
		loadRouteAction.apply(initialRoute).start()
	}

	func loadNext() {
		guard let nextLink = nextLink.value else { return }
		loadURLAction.apply(nextLink).start()
	}

	func loadCurrent() {
		guard let currentLink = currentLink.value else { loadFirst(); return }
		loadURLAction.apply(currentLink).start()
	}
}
