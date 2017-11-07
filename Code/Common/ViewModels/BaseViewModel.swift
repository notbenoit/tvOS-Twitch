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

import UIKit
import ReactiveSwift
import DataSource

class BaseViewModel<Response: ListResponseType, ViewModel: Equatable> {
	let paginator: Paginator<Response>
	let viewModels: MutableProperty<[ViewModel]>
	let dataSource: DataSource

	init(_ apiRoute: TwitchRouter, transform: @escaping ((Response.Element) -> ViewModel?)) {
		paginator = Paginator<Response>(apiRoute)

		let autoDiff = AutoDiffDataSource<ViewModel>(compare: ==)
		viewModels = autoDiff.items
		viewModels <~ paginator.lastResponse.producer.combinePrevious(nil).scan([]) { objects, previousAndNext in
			switch (previousAndNext.0, previousAndNext.1) {
			case (.none, .some(let response)):
				return response.objects.flatMap(transform)
			case (.some, .some(let response)):
				return objects + response.objects.flatMap(transform)
			case (_, .none):
				return objects
			}
		}

		let loadMoreItem = LoadMoreCellItem()
		let loadMoreDataSource = ProxyDataSource()
		loadMoreDataSource.innerDataSource <~ paginator.allLoaded.producer
			.map { $0 ? EmptyDataSource() : StaticDataSource(items: [loadMoreItem]) as DataSource }

		dataSource = ProxyDataSource(CompositeDataSource([autoDiff, loadMoreDataSource]), animateChanges: false)

		#if os(iOS)
			UIApplication.shared.reactive.isNetworkIndicatorVisible <~ paginator.loadingState.map { $0.loading }
		#endif
	}

	func loadMore() {
		paginator.loadNext()
	}

	func reload() {
		paginator.loadCurrent()
	}
}
