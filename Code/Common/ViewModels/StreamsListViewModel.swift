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
import UIKit
import ReactiveCocoa
import Result
import DataSource

final class StreamsListViewModel {
	let refreshAction = Action(StreamsListViewModel.loadPage)
	
	// Data
	private let totalCount = MutableProperty<Int>(0)
	private var page = MutableProperty<Int>(0)
	let streams = MutableProperty<[StreamViewModel]>([])
	
	// Cell models
	let dataSource: DataSource
	
	let gameName: String?
	
	init(gameName: String? = nil) {
		self.gameName = gameName
		#if os(iOS)
			UIApplication.sharedApplication().rac_networkIndicatorVisible <~ refreshAction.executing
		#endif
		
		streams <~ refreshAction.values.scan([]) {
			let duplicates = Set($0.0).intersect($0.1.objects)
			return $0.0 + $0.1.objects.filter { !duplicates.contains($0) } }
			.map { $0.map { StreamViewModel(stream: $0) } }
		totalCount <~ refreshAction.values.map { $0.count }
		page <~ refreshAction.values.scan(0) { $0.0 + 1 }
		refreshAction.errors.observeNext { print($0) }
		let loadMoreItem = LoadMoreCellItem()
		loadMoreItem.loadingState <~ refreshAction.loadingState
		let loadMoreDataSource = ProxyDataSource()
		let allLoaded = combineLatest(totalCount.producer, streams.producer)
			.map { $0.0 <= $0.1.count }
		loadMoreDataSource.innerDataSource <~ allLoaded
			.map { $0 ? EmptyDataSource() : StaticDataSource(items: [loadMoreItem]) as DataSource }
		
		let autoDiffDataSource = AutoDiffDataSource<StreamViewModel>(compare: ==)
		autoDiffDataSource.items <~ streams
		dataSource = CompositeDataSource([autoDiffDataSource, loadMoreDataSource])
		
		loadMore()
	}
	
	func loadMore() {
		refreshAction.apply((gameName, page.value)).start()
	}
	
	private static func loadPage(gameName: String?, page: Int) -> SignalProducer<StreamsResponse, NSError> {
		return TwitchAPIClient.sharedInstance.streamForGame(gameName, page: page)
	}
}