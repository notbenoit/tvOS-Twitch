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
import ReactiveSwift
import DataSource

final class GamesViewController: UIViewController {

	let gameCellWidth: CGFloat = 148.0
	let horizontalSpacing: CGFloat = 51.0

	var onGameSelected: ((Game) -> Void)?
	
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var loadingStateView: LoadingStateView!
	
	let gameListViewModel = GamesList.ViewModelType(TwitchRouter.gamesTop(page: 0), transform: GamesList.gameToViewModel)
	
	let collectionDataSource = CollectionViewDataSource()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.itemSize = CGSize(width: gameCellWidth, height: gameCellWidth/Constants.gameImageRatio)
		layout.minimumInteritemSpacing = horizontalSpacing
		layout.minimumLineSpacing = horizontalSpacing
		
		collectionDataSource.reuseIdentifierForItem = { _, item in
			if let item = item as? ReuseIdentifierProvider {
				return item.reuseIdentifier
			}
			fatalError()
		}
		collectionDataSource.dataSource.innerDataSource.value = gameListViewModel.dataSource
		collectionDataSource.collectionView = collectionView
		collectionView.dataSource = collectionDataSource
		
		collectionView.register(GameCell.nib, forCellWithReuseIdentifier: GameCell.identifier)
		collectionView.register(LoadMoreCell.nib, forCellWithReuseIdentifier: LoadMoreCell.identifier)
		collectionView.collectionViewLayout = layout
		collectionView.delegate = self

		collectionView.remembersLastFocusedIndexPath = true

		loadingStateView.reactive.loadingState <~ gameListViewModel.paginator.loadingState
		loadingStateView.reactive.isEmpty <~ gameListViewModel.viewModels.producer.map { $0.isEmpty }
		loadingStateView.retry = { [weak self] in self?.gameListViewModel.reload() }
	}
}

extension GamesViewController: UICollectionViewDelegate {

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let currentRight = scrollView.contentOffset.x + scrollView.frame.size.width
		if currentRight >= (scrollView.contentSize.width - 200.0) {
			gameListViewModel.loadMore()
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let item = collectionDataSource.dataSource.item(at: indexPath) as? GameCellViewModel {
			onGameSelected?(item.game)
		}
	}
}

