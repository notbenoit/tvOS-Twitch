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
import ReactiveSwift
import ReactiveCocoa
import DataSource
import Result

final class StreamsViewController: UIViewController {

	let streamCellWidth: CGFloat = 308.0
	let horizontalSpacing: CGFloat = 50.0
	let verticalSpacing: CGFloat = 100.0

	let presentStream: Action<(stream: Stream, controller: UIViewController), AVPlayerViewController, AnyError> = Action(execute: controllerProducerForStream)

	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var loadingView: LoadingStateView!
	@IBOutlet var noItemsLabel: UILabel!
	@IBOutlet var loadingStreamView: UIView!
	@IBOutlet var loadingMessage: UILabel!

	let viewModel = MutableProperty<StreamList.ViewModelType?>(nil)
	let collectionDataSource = CollectionViewDataSource()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor.twitchDark

		collectionDataSource.reuseIdentifierForItem = { _, item in
			if let item = item as? ReuseIdentifierProvider {
				return item.reuseIdentifier
			}
			fatalError()
		}

		loadingStreamView.reactive.isHidden <~ presentStream.isExecuting.producer.map(!)
		
		loadingMessage.reactive.text <~ presentStream.isExecuting.producer
			.filter { $0 }
			.map { _ in LoadingMessages.randomMessage }
		
		collectionDataSource.dataSource.innerDataSource <~ viewModel.producer.map { $0?.dataSource ?? EmptyDataSource() }
		collectionDataSource.collectionView = collectionView
		collectionView.dataSource = collectionDataSource

		noItemsLabel.text = NSLocalizedString("No game selected yet. Pick a game in the upper list.", comment: "")
		noItemsLabel.reactive.isHidden <~ viewModel.producer.map { $0 != nil }

		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		layout.itemSize = CGSize(width: streamCellWidth, height: 250.0)
		layout.sectionInset = UIEdgeInsets(top: 60, left: 90, bottom: 60, right: 90)
		layout.minimumInteritemSpacing = horizontalSpacing
		layout.minimumLineSpacing = verticalSpacing

		collectionView.register(StreamCell.nib, forCellWithReuseIdentifier: StreamCell.identifier)
		collectionView.register(LoadMoreCell.nib, forCellWithReuseIdentifier: LoadMoreCell.identifier)

		collectionView.collectionViewLayout = layout
		collectionView.delegate = self

		loadingView.reactive.loadingState <~ viewModel.producer.skipNil().chain { $0.paginator.loadingState }
		loadingView.reactive.isEmpty <~ viewModel.producer.skipNil().chain { $0.viewModels }.map { $0.isEmpty }
		loadingView.retry = { [weak self] in self?.viewModel.value?.paginator.loadFirst() }
		
		presentStream.values
			.observe(on: UIScheduler())
			.observeValues { [weak self] in self?.present($0, animated: true, completion: nil) }
	}

}

extension StreamsViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let item = collectionDataSource.dataSource.item(at: indexPath) as? StreamViewModel {
			presentStream.apply((item.stream, self)).start()
		}
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let contentOffsetY = scrollView.contentOffset.y + scrollView.bounds.size.height
		let wholeHeight = scrollView.contentSize.height

		let remainingDistanceToBottom = wholeHeight - contentOffsetY

		if remainingDistanceToBottom <= 600 {
			viewModel.value?.loadMore()
		}
	}
}

private func controllerProducerForStream(_ stream: Stream, inController: UIViewController) -> SignalProducer<AVPlayerViewController, AnyError> {
	return TwitchAPIClient.sharedInstance.m3u8URLForChannel(stream.channel.channelName)
		.on(started: { UIApplication.shared.beginIgnoringInteractionEvents() })
		.map { $0.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) }
		.map { $0.flatMap { URL(string: $0) } }
		.skipNil()
		.map { (url: URL) -> AVPlayerViewController in
			let playerController = AVPlayerViewController()
			playerController.view.frame = UIScreen.main.bounds
			let avPlayer = AVPlayer(url: url)
			playerController.player = avPlayer
			return playerController
	}
		.on() { _ in UIApplication.shared.endIgnoringInteractionEvents() }
		.on(terminated: { UIApplication.shared.endIgnoringInteractionEvents() })
		.observe(on: UIScheduler())
		.on() { $0.player?.play() }
}
