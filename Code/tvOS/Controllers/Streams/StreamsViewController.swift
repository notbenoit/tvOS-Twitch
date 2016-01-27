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
import AVKit
import ReactiveCocoa

class StreamsViewController: UIViewController {

	let streamCellWidth: CGFloat = 308.0
	let horizontalSpacing: CGFloat = 50.0
	let verticalSpacing: CGFloat = 100.0
	
	let presentStream: Action<(stream: Stream, controller: UIViewController), Void, NSError> = Action {
		pair in
		TwitchAPIClient.sharedInstance.m3u8URLForChannel(pair.stream.channel.channelName).flatMap(.Latest) {
			urlString in
			return SignalProducer {
				observer, disposable in
				let playerController = AVPlayerViewController()
				let escapedURLString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
				guard let escapedString = escapedURLString, url = NSURL(string: escapedString) else { observer.sendFailed(Constants.genericError); return }
				let avPlayer = AVPlayer(URL: url)
				avPlayer.play()
				playerController.player = avPlayer
				pair.controller.presentViewController(playerController, animated: true) {
					observer.sendCompleted()
				}
			}
		}
	}
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var noItemsLabel: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	var streamListDataSource = MutableProperty<StreamsDataSource?>(nil)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.twitchDarkColor()
		
		presentStream.errors.observeNext {
			self.presentDefaultError($0)
		}
		
		let nonNilDataSource = streamListDataSource.producer.ignoreNil()
		let streamListVm = nonNilDataSource.flatMap(.Latest) { $0.streamListViewModel.producer }
		nonNilDataSource.startWithNext { [weak self] in self?.collectionView.dataSource = $0 }
		noItemsLabel.rac_hidden <~ streamListVm.producer.flatMap(.Latest) { $0.hideLabel.producer }
		activityIndicator.rac_hidden <~ streamListVm.producer.flatMap(.Latest) { $0.showBigLoader.producer }.map { !$0 }
		streamListVm.producer.flatMap(.Latest) { $0.data.producer }
			.startWithNext { [weak self] _ in self?.collectionView.reloadData() }
		
		noItemsLabel.text = NSLocalizedString("No game selected yet. Pick a game in the upper list.", comment: "")
		noItemsLabel.font = UIFont.systemFontOfSize(42)
		noItemsLabel.textColor = UIColor.whiteColor()
		
		activityIndicator.hidden = true
		
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .Vertical
		layout.itemSize = CGSize(width: streamCellWidth, height: 250.0)
		layout.sectionInset = UIEdgeInsets(top: 60, left: 90, bottom: 60, right: 90)
		layout.minimumInteritemSpacing = horizontalSpacing
		layout.minimumLineSpacing = verticalSpacing
		
		collectionView.registerNib(UINib(nibName: "StreamCell", bundle: nil), forCellWithReuseIdentifier: StreamCell.identifier)
		collectionView.collectionViewLayout = layout
		collectionView.delegate = self
	}
}

extension StreamsViewController: UICollectionViewDelegate {
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		guard let streamListDataSource = streamListDataSource.value else { return }
		presentStream.apply((streamListDataSource.streamListViewModel.value.data.value[indexPath.row], self)).start()
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		guard let streamListDataSource = streamListDataSource.value else { return }
		let contentOffsetY = scrollView.contentOffset.y + scrollView.bounds.size.height
		let wholeHeight = scrollView.contentSize.height
		
		let remainingDistanceToBottom = wholeHeight - contentOffsetY
		
		if remainingDistanceToBottom <= 200 {
			streamListDataSource.loadMore()
		}
	}
}


