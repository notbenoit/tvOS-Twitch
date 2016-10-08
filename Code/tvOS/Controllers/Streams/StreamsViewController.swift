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
import DataSource
import Result

final class StreamsViewController: UIViewController {

	let streamCellWidth: CGFloat = 308.0
	let horizontalSpacing: CGFloat = 50.0
	let verticalSpacing: CGFloat = 100.0

	let presentStream: Action<(stream: Stream, controller: UIViewController), AVPlayerViewController, NSError> = Action(controllerProducerForStream)

	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var loadingView: LoadingStateView!
	@IBOutlet var noItemsLabel: UILabel!

	let viewModel = MutableProperty<StreamList.ViewModelType?>(nil)
	let collectionDataSource = CollectionViewDataSource()

	fileprivate let disposable = CompositeDisposable()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.twitchDarkColor()

		collectionDataSource.reuseIdentifierForItem = { _, item in
			if let item = item as? ReuseIdentifierProvider {
				return item.reuseIdentifier
			}
			fatalError()
		}

		collectionDataSource.dataSource.innerDataSource <~ viewModel.producer.map { $0?.dataSource ?? EmptyDataSource() }
		collectionDataSource.collectionView = collectionView
		collectionView.dataSource = collectionDataSource

		noItemsLabel.text = NSLocalizedString("No game selected yet. Pick a game in the upper list.", comment: "")
		noItemsLabel.font = UIFont.systemFont(ofSize: 42)
		noItemsLabel.textColor = UIColor.white
		noItemsLabel.rac_hidden <~ viewModel.producer.map { $0 != nil }

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

		loadingView.loadingState <~ viewModel.producer.skipNil().chain { $0.paginator.loadingState }
		loadingView.isEmpty <~ viewModel.producer.skipNil().chain { $0.viewModels }.map { $0.isEmpty }
		loadingView.retry = { [weak self] in self?.viewModel.value?.paginator.loadFirst() }

		disposable += presentStream.values
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

private func controllerProducerForStream(_ stream: Stream, inController: UIViewController) -> SignalProducer<AVPlayerViewController, NSError> {
	return TwitchAPIClient.sharedInstance.m3u8URLForChannel(stream.channel.channelName)
		.map { $0.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) }
		.map { $0.flatMap { URL(string: $0) } }
		.skipNil()
		.map {
			let playerController = AVPlayerViewController()
			playerController.view.frame = UIScreen.main.bounds
			let avPlayer = AVPlayer(url: $0)
			playerController.player = avPlayer
			return playerController
	}
		.flatMap(.latest) {
			(controller: AVPlayerViewController) -> SignalProducer<AVPlayerViewController, NSError> in
			return adProducerBeforeController(controller, inController: inController, placement: "BetweenLevels")
		}
		.on(value: { $0.player?.play() })
}
