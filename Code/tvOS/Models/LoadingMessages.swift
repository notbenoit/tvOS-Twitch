//
//  LoadingMessages.swift
//  TwitchTV
//
//  Created by Benoît Layer on 09/10/2016.
//  Copyright © 2016 Benoit Layer. All rights reserved.
//

import Foundation

struct LoadingMessages {
	private static let loadingMessages: [String] = [
		"Loading your show...",
		"Loading... We promess the video will start before Star Citizen is released...",
		"Loading... We promess the video will start before Half-Life 3 is released...",
		"Loading... We might show you an ad before, sorry about that..."
	]
	
	static var randomMessage: String {
		let index = Int(arc4random_uniform(UInt32(loadingMessages.count)))
		return loadingMessages[index]
	}
}

