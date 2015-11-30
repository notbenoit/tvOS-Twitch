//
//  ListResponse.swift
//  TwitchTV
//
//  Created by Benoît Layer on 30/11/2015.
//  Copyright © 2015 Benoit Layer. All rights reserved.
//

import Foundation

struct ListResponse<T> {
	let objects: [T]
	let count: Int
}