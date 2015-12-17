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

final class StreamListViewModel {
	
	let loadingState = MutableProperty<LoadingState>(.Available)
	let showBigLoader = MutableProperty<Bool>(false)
	let hideLabel = MutableProperty<Bool>(false)
	let twitchClient = TwitchAPIClient.sharedInstance
	
	let data = MutableProperty<[Stream]>([Stream]())
	let totalCount = MutableProperty<Int>(0)
	
	let gameName: String?
	let refreshAction: Action<(gameName: String?, page: Int), ListResponse<Stream>, NSError> = Action { pair in
		TwitchAPIClient.sharedInstance.streamForGame(pair.0, page: pair.1)
	}
	
	private let page = MutableProperty<Int>(0)
	
	init(game: String?) {
		gameName = game
		#if os(iOS)
			self.loadingState.producer.startWithNext { state in
				UIApplication.sharedApplication().networkActivityIndicatorVisible = state == .Loading
			}
		#endif
		loadingState <~ refreshAction.executing.producer.map { $0 ? .Loading : .Available }
		data <~ refreshAction.values.scan([]) { $0 + $1.objects }
		page <~ refreshAction.values.scan(0) { $0.0 + 1 }
		totalCount <~ refreshAction.values.map { $0.count }
		hideLabel <~ refreshAction.executing.producer
			.combineLatestWith(data.producer)
			.map { $0.0 || $0.1.count > 0 }
		showBigLoader <~ refreshAction.executing.producer
			.combineLatestWith(data.producer)
			.map { $0.0 && $0.1.count == 0 }
		loadMore()
	}
	
	func loadMore() {
		refreshAction.apply((gameName, page.value)).start()
	}
}