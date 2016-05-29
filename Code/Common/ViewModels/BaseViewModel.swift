//
//  BaseViewModel.swift
//  TwitchTV
//
//  Created by Benoît Layer on 10/04/2016.
//  Copyright © 2016 Benoit Layer. All rights reserved.
//

import Foundation
import ReactiveCocoa
import DataSource

class BaseViewModel<Response: ListResponseType, ViewModel: Equatable> {
	let paginator: Paginator<Response>
	let viewModels: MutableProperty<[ViewModel]>
	let dataSource: DataSource
	private let disposable = CompositeDisposable()

	init(_ apiRoute: TwitchRouter, transform: (Response.Element -> ViewModel?)) {
		paginator = Paginator<Response>(apiRoute)

		let autoDiffDs = AutoDiffDataSource<ViewModel>(compare: ==)
		viewModels = autoDiffDs.items
		disposable += viewModels <~ paginator.lastResponse.producer.combinePrevious(nil).scan([]) {
			objects, previousAndNext in
			switch (previousAndNext.0, previousAndNext.1) {
			case (.None, .Some(let response)):
				return response.objects.flatMap(transform)
			case (.Some, .Some(let response)):
				return objects + response.objects.flatMap(transform)
			case (_, .None):
				return objects
			}
		}

		let loadMoreItem = LoadMoreCellItem()
		let loadMoreDataSource = ProxyDataSource()
		disposable += loadMoreDataSource.innerDataSource <~ paginator.allLoaded.producer
			.map { $0 ? EmptyDataSource() : StaticDataSource(items: [loadMoreItem]) as DataSource }

		dataSource = ProxyDataSource(CompositeDataSource([autoDiffDs, loadMoreDataSource]), animateChanges: false)

		#if os(iOS)
			disposable += UIApplication.sharedApplication().rac_networkIndicatorVisible <~ paginator.loadingState.map { $0.loading }
		#endif
	}

	deinit {
		disposable.dispose()
	}

	func loadMore() {
		paginator.loadNext()
	}

	func reload() {
		paginator.loadCurrent()
	}
}
