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
import TVServices
import ReactiveCocoa

class ServiceProvider: NSObject, TVTopShelfProvider {

	let twitchClient = TwitchAPIClient()
	
	override init() {
	    super.init()
	}

	// MARK: - TVTopShelfProvider protocol

	var topShelfStyle: TVTopShelfContentStyle {
	    // Return desired Top Shelf style.
	    return .Sectioned
	}

	var topShelfItems: [TVContentItem] {
		let semaphore = dispatch_semaphore_create(0)
		let topGamesItem = TVContentItem(contentIdentifier: TVContentIdentifier(identifier: "topGames", container: nil)!)!
		topGamesItem.title = "Top Games"
		var items: [TVContentItem] = []
		twitchClient.getTopGames(0).on(failed: {
			error in
			dispatch_semaphore_signal(semaphore)
			})
			.startWithResult {
				items += (try? ($0.dematerialize()).objects.map {
					let item = TVContentItem(contentIdentifier: TVContentIdentifier(identifier: String($0.game.id), container: nil)!)
					let components = NSURLComponents()
					components.scheme = "twitch"
					components.path = "game"
					components.queryItems = [NSURLQueryItem(name: "name", value: $0.game.gameNameString)]
					item?.imageShape = .Poster
					item?.displayURL = components.URL!
					item?.imageURL = NSURL(string: $0.game.box.large)!
					item?.title = $0.game.gameNameString
					return item!
				}) ?? []
				dispatch_semaphore_signal(semaphore)
		}

		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		topGamesItem.topShelfItems = items
		return [topGamesItem]
	}
	
}

