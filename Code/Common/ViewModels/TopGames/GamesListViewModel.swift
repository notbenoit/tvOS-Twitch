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
	// Data
	let gamesPaginator = Paginator<TopGamesResponse>(TwitchRouter.GamesTop(page: 0))
	private let nonFilteredTopGames: MutableProperty<[TopGame]>
	let topGames = MutableProperty<[GameCellViewModel]>([])
	
	// Cell models
	let dataSource: DataSource
	
	init() {
		#if os(iOS)
			UIApplication.sharedApplication().rac_networkIndicatorVisible <~ refreshAction.executing
		#endif

		nonFilteredTopGames = gamesPaginator.objects
		topGames <~ nonFilteredTopGames.producer
			.map { $0.filter(GamesListViewModel.nintendoFilter) }
			.map { $0.map { GameCellViewModel(game: $0.game) } }
		
		let loadMoreItem = LoadMoreCellItem()
		loadMoreItem.loadingState <~ gamesPaginator.loadingState
		let loadMoreDataSource = ProxyDataSource()
		loadMoreDataSource.innerDataSource <~ gamesPaginator.allLoaded.producer
			.map { $0 ? EmptyDataSource() : StaticDataSource(items: [loadMoreItem]) as DataSource }
		
		let autoDiffDataSource = AutoDiffDataSource<GameCellViewModel>(compare: ==)
		autoDiffDataSource.items <~ topGames
		dataSource = ProxyDataSource(CompositeDataSource([autoDiffDataSource, loadMoreDataSource]), animateChanges: false)
	}
	
	func loadMore() {
		gamesPaginator.loadNext()
	}
	
	private static func nintendoFilter(game: TopGame) -> Bool {
		return !(game.game.gameNameString.containsString("Mario") || game.game.gameNameString.containsString("Bros"))
	}
}
