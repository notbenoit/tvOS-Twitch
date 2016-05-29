//
//  SearchResultsViewController.swift
//  TwitchTV
//
//  Created by Benoît Layer on 10/04/2016.
//  Copyright © 2016 Benoit Layer. All rights reserved.
//

import UIKit
import DataSource
import ReactiveCocoa

final class SearchResultsViewController: UIViewController, UISearchResultsUpdating {

	private var streamsViewController: StreamsViewController!

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		switch segue.destinationViewController {
		case let controller as StreamsViewController:
			streamsViewController = controller
		default:
			super.prepareForSegue(segue, sender: sender)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		streamsViewController.noItemsLabel.text = NSLocalizedString("Search for a game, channel, user...", comment: "")
	}

	func updateSearchResultsForSearchController(searchController: UISearchController) {
		guard let text = searchController.searchBar.text where !text.isEmpty else { return }
		streamsViewController.viewModel.value = StreamList.ViewModelType(TwitchRouter.SearchStream(query: text, page: 0), transform: StreamList.streamToViewModel)
	}

}
