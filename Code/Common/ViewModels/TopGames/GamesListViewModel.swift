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
import ReactiveCocoa
import DataSource

struct GamesListViewModel {
	let refreshAction = Action(GamesListViewModel.loadPage)
	
	// Data
	private let nonFilteredTopGames = MutableProperty<[TopGame]>([])
	private let totalCount = MutableProperty<Int>(0)
	private var page = MutableProperty<Int>(0)
	let topGames = MutableProperty<[GameCellViewModel]>([])
	
	// Cell models
	let dataSource: DataSource
	
	init() {
		#if os(iOS)
			UIApplication.sharedApplication().rac_networkIndicatorVisible <~ refreshAction.executing
		#endif

		nonFilteredTopGames <~ refreshAction.values.scan([]) { Array(Set($0.0).union($0.1.objects)).sort(>) }
		topGames <~ nonFilteredTopGames.producer
			.map { $0.filter(GamesListViewModel.nintendoFilter) }
			.map { $0.map { GameCellViewModel(game: $0.game) } }
		totalCount <~ refreshAction.values.map { $0.count }
		page <~ refreshAction.values.scan(0) { $0.0 + 1 }
		
		let loadMoreItem = LoadMoreCellItem()
		loadMoreItem.loadingState <~ refreshAction.loadingState
		let loadMoreDataSource = ProxyDataSource()
		let allLoaded = combineLatest(totalCount.producer, nonFilteredTopGames.producer)
			.map { $0.0 <= $0.1.count }
		loadMoreDataSource.innerDataSource <~ allLoaded
			.map { $0 ? EmptyDataSource() : StaticDataSource(items: [loadMoreItem]) as DataSource }
		
		let autoDiffDataSource = AutoDiffDataSource<GameCellViewModel>(compare: ==)
		autoDiffDataSource.items <~ topGames
		dataSource = ProxyDataSource(CompositeDataSource([autoDiffDataSource, loadMoreDataSource]), animateChanges: false)
		
		loadMore()
	}
	
	func loadMore() {
		refreshAction.apply(page.value).start()
	}
	
	private static func loadPage(page: Int) -> SignalProducer<TopGamesResponse, NSError> {
		return TwitchAPIClient.sharedInstance.getTopGames(page)
	}
	
	private static func nintendoFilter(game: TopGame) -> Bool {
		return !(game.game.gameNameString.containsString("Mario") || game.game.gameNameString.containsString("Bros"))
	}
}
