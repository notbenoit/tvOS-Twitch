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
import DataSource
import ReactiveSwift

final class SearchResultsViewController: UIViewController, UISearchResultsUpdating {

	fileprivate var streamsViewController: StreamsViewController!

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.destination {
		case let controller as StreamsViewController:
			streamsViewController = controller
		default:
			super.prepare(for: segue, sender: sender)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		streamsViewController.noItemsLabel.text = NSLocalizedString("Search for a game, channel, user...", comment: "")
	}

	func updateSearchResults(for searchController: UISearchController) {
		guard let text = searchController.searchBar.text , !text.isEmpty else { return }
		streamsViewController.viewModel.value = StreamList.ViewModelType(TwitchRouter.searchStream(query: text, page: 0), transform: StreamList.streamToViewModel)
	}

}
