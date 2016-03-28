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

enum LoadingState {
	case Available
	case Loading
	case Error
}

struct GameListViewModel {
	let loadingState = MutableProperty<LoadingState>(.Available)
	let twitchClient = TwitchAPIClient.sharedInstance
	
	let refreshAction: Action<Int, TopGamesResponse, NSError> = Action { page in
		TwitchAPIClient.sharedInstance.getTopGames(page)
	}
	
	let data = MutableProperty<Set<TopGame>>(Set<TopGame>())
	let totalCount = MutableProperty<Int>(0)
	
	let orderedGames = MutableProperty<[TopGame]>([])
	let showLoader = MutableProperty<Bool>(false)
	
	private let page = MutableProperty<Int>(0)
	
	init() {
		#if os(iOS)
		self.loadingState.producer.startWithNext { state in
			UIApplication.sharedApplication().networkActivityIndicatorVisible = state == .Loading
		}
		#endif
		loadingState <~ refreshAction.executing.producer.map { $0 ? .Loading : .Available }
		orderedGames <~ data.producer.map { $0.sort(>) }
		showLoader <~ refreshAction.executing.producer
			.combineLatestWith(data.producer)
			.map { $0.0 && $0.1.count == 0 }
		data <~ refreshAction.values.scan(Set<TopGame>()) { $0.0.union($0.1.objects.filter(nintendoFilter)) }
		totalCount <~ refreshAction.values.map { $0.count }
		page <~ refreshAction.values.scan(0) { $0.0 + 1 }
	}
	
	func loadMore() {
		refreshAction.apply(page.value).start()
	}
}

private func nintendoFilter(game: TopGame) -> Bool {
	return !(game.game.gameNameString.containsString("Mario") || game.game.gameNameString.containsString("Bros"))
}
