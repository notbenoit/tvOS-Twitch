//
//  ServiceProvider.swift
//  TopShelf
//
//  Created by Benoît Layer on 12/11/2015.
//  Copyright © 2015 Benoit Layer. All rights reserved.
//

import Foundation
import TVServices

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
			.startWithNext {
				items += $0.objects.map {
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
				}
				dispatch_semaphore_signal(semaphore)
		}

		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		topGamesItem.topShelfItems = items
		return [topGamesItem]
	}
	
}

