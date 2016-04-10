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
	let elements: MutableProperty<[Response.Element]>
	
	let viewModels: MutableProperty<[ViewModel]>
	
	let dataSource: DataSource
	
	init(_ apiRoute: TwitchRouter, transform: (Response.Element -> ViewModel?)) {
		paginator = Paginator<Response>(apiRoute)
		elements = paginator.objects
		
		let autoDiffDs = AutoDiffDataSource<ViewModel>(compare: ==)
		viewModels = autoDiffDs.items
		viewModels <~ elements.producer.map { $0.flatMap(transform) }
		
		let loadMoreItem = LoadMoreCellItem()
		let loadMoreDataSource = ProxyDataSource()
		loadMoreDataSource.innerDataSource <~ paginator.allLoaded.producer
			.map { $0 ? EmptyDataSource() : StaticDataSource(items: [loadMoreItem]) as DataSource }
		
		dataSource = ProxyDataSource(CompositeDataSource([autoDiffDs, loadMoreDataSource]), animateChanges: false)

		#if os(iOS)
			UIApplication.sharedApplication().rac_networkIndicatorVisible <~ paginator.loadingState.map { $0.loading }
		#endif
	}
	
	func loadMore() {
		paginator.loadNext()
	}
	
	func reload() {
		paginator.loadCurrent()
	}
}