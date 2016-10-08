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
import ReactiveSwift
import Result

// MARK: - Links
struct Links {
	let current: String?
	let next: String?
}

extension Links: JSONParsing {
	static func parse(_ json: JSON) throws -> Links {
		return try Links(
			current: json["self"].optional.map(^),
			next: json["next"].optional.map(^))
	}
}

// MARK: - List Response
protocol ListResponseType: JSONParsing {
	associatedtype Element: JSONParsing
	var objects: [Element] { get }
	var count: Int { get }
	var links: Links { get }

	static var rootPath: String { get }

	init(objects: [Element], count: Int, links: Links)
}

extension ListResponseType {
	static func parse(_ json: JSON) throws -> Self {
		return try Self(
			objects: json[self.rootPath].array.map(^),
			count: json["_total"]^,
			links: json["_links"]^)
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

class Paginator<Response: ListResponseType> {
	let objects = MutableProperty<[Response.Element]>([])
	let loadURLAction: Action<String, Response, NSError>
	let loadRouteAction: Action<TwitchRouter, Response, NSError>
	let initialRoute: TwitchRouter

	let lastResponse = MutableProperty<Response?>(nil)
	let totalCount = MutableProperty<Int?>(nil)
	let allLoaded = MutableProperty<Bool>(false)

	var nextLink: String?
	var currentLink: String?

	let loadingState: SignalProducer<LoadingState<NSError>, NoError>
	
	private let disposable = CompositeDisposable()

	init(_ initialRoute: TwitchRouter) {
		self.initialRoute = initialRoute
		loadURLAction = Action(TwitchAPIClient.sharedInstance.request)
		loadRouteAction = Action(TwitchAPIClient.sharedInstance.request)
		loadingState = SignalProducer(values: [loadURLAction.loadingState, loadRouteAction.loadingState]).flatten(.merge)

		allLoaded <~ SignalProducer.combineLatest(totalCount.producer.skipNil(), objects.producer).map {
			return $0.0 <= $0.1.count
		}

		disposable += loadRouteAction.values.observeValues { [weak self] in
			self?.objects.value = $0.objects
			self?.nextLink = $0.links.next
			self?.currentLink = $0.links.current
			self?.lastResponse.value = $0
		}

		disposable += loadURLAction.values.observeValues { [weak self] in
			self?.lastResponse.value = $0
			self?.objects.value += $0.objects
			self?.nextLink = $0.links.next
			self?.currentLink = $0.links.current
		}

		loadFirst()
	}

	func loadFirst() {
		objects.value = []
		lastResponse.value = nil
		nextLink = nil
		currentLink = nil
		loadRouteAction.apply(initialRoute).start()
	}

	func loadNext() {
		guard let nextLink = nextLink else { return }
		loadURLAction.apply(nextLink).start()
	}

	func loadCurrent() {
		guard let currentLink = currentLink else { loadFirst(); return }
		loadURLAction.apply(currentLink).start()
	}
}
