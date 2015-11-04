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
	
	let data = MutableProperty<[Game]>([Game]())
	let totalCount = MutableProperty<Int>(0)
	
	private let page = MutableProperty<Int>(0)
	
	init() {
		#if os(iOS)
		self.loadingState.producer.startWithNext { state in
			UIApplication.sharedApplication().networkActivityIndicatorVisible = state == .Loading
		}
		#endif
	}
	
	func loadMore() {
		twitchClient.getTopGames(page.value)
			.on(started: {
				self.loadingState.value = .Loading
			})
			.on(completed: {
				self.loadingState.value = .Available
				self.page.value = self.page.value + 1
			})
			.startWithNext { response in
				self.data.value = self.data.value + response.objects
				self.totalCount.value = response.count
			}
	}
}