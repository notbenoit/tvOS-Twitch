//
//  HomeTabBarController.swift
//  TwitchTV
//
//  Created by Benoît Layer on 17/12/2015.
//  Copyright © 2015 Benoit Layer. All rights reserved.
//

import UIKit

class HomeTabBarDelegate: NSObject, UITabBarControllerDelegate {
	func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
		if let
			controller = viewController as? StreamsViewController,
			identifier = controller.restorationIdentifier where identifier == "Streams" && controller.streamListDataSource.value == nil {
				let dataSource = StreamsDataSource(streamListVM: StreamListViewModel(game: nil))
				controller.streamListDataSource.value = dataSource
		}
	}
}