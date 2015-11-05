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

class GamesViewController: UIViewController {

	let gameCellWidth: CGFloat = 148.0
	let horizontalSpacing: CGFloat = 51.0
	let verticalSpacing: CGFloat = 100.0
	
	var onGameSelected: (Game -> ())?
	
	@IBOutlet weak var collectionView: UICollectionView!
	let gameListDataSource = GamesDataSource()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.whiteColor()
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .Horizontal
		layout.itemSize = CGSize(width: gameCellWidth, height: gameCellWidth/Constants.gameImageRatio)
		layout.sectionInset = UIEdgeInsets(top: 60, left: 90, bottom: 60, right: 90)
		layout.minimumInteritemSpacing = horizontalSpacing
		layout.minimumLineSpacing = verticalSpacing
		
		collectionView.registerNib(UINib(nibName: "GameCell", bundle: nil), forCellWithReuseIdentifier: GameCell.identifier)
		collectionView.collectionViewLayout = layout
		collectionView.dataSource = gameListDataSource
		collectionView.delegate = self
		
		gameListDataSource.gameListViewModel.data.producer.startWithNext {
			[weak self] games in
			self?.collectionView.reloadData()
		}
		
		gameListDataSource.loadMore()
	}
}

extension GamesViewController: UICollectionViewDelegate {
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let game = gameListDataSource.gameListViewModel.orderedGames.value[indexPath.row].game
		onGameSelected?(game)
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		let contentOffsetX = scrollView.contentOffset.x + scrollView.bounds.size.width
		let wholeWidth = scrollView.contentSize.width
		
		let remainingDistanceToRight = wholeWidth - contentOffsetX
		
		if remainingDistanceToRight <= 1920 && gameListDataSource.gameListViewModel.loadingState.value == .Available {
			gameListDataSource.gameListViewModel.loadMore()
		}
	}
}

