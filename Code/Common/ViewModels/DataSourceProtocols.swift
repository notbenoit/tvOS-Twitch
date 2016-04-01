//
//  DataSourceProtocols.swift
//  TwitchTV
//
//  Created by Benoît Layer on 31/03/2016.
//  Copyright © 2016 Benoit Layer. All rights reserved.
//

import UIKit

protocol HeightProvider {
	var height: CGFloat { get }
}

protocol ReuseIdentifierProvider {
	var reuseIdentifier: String { get }
}

