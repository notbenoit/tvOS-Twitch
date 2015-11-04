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

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	private let cellIdentifierGame = "GameCellIdentifier"
	private var cellSpacing: CGFloat = 10.0
	private let numberOfCellsInARow = 2
	private var sectionInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
	
	@IBOutlet var collectionView: UICollectionView! {
		didSet {
			collectionView.backgroundColor = UIColor.clearColor()
			collectionView.dataSource = self
			collectionView.delegate = self
			
			collectionView.registerNib(UINib(nibName: "GameCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifierGame)
		}
	}
	
	let gameListViewModel = GameListViewModel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = UIColor.whiteColor()
		
		gameListViewModel.loadMore()
		gameListViewModel.data.producer.startWithNext {
			games in
			self.collectionView.reloadData()
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifierGame, forIndexPath: indexPath) as! GameCell
		cell.bindViewModel(GameViewModel(game: gameListViewModel.data.value[indexPath.row]))
		return cell
	}
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return gameListViewModel.data.value.count
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
		return cellSpacing
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
		return cellSpacing
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
		return sectionInset
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		var width: CGFloat = (collectionView.bounds.size.width - sectionInset.left) / CGFloat(numberOfCellsInARow)
		width = width - (CGFloat(numberOfCellsInARow) - 1) * cellSpacing
		return CGSize(width: width, height: width*1.40)
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		let contentOffsetY = scrollView.contentOffset.y + scrollView.bounds.size.height
		let wholeHeight = scrollView.contentSize.height
		
		let remainingDistanceToBottom = wholeHeight - contentOffsetY
		
		if remainingDistanceToBottom <= 200 && gameListViewModel.loadingState.value == .Available {
			gameListViewModel.loadMore()
		}
	}
}

