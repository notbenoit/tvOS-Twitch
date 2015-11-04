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
import ReactiveCocoa
import AlamofireImage

class GameCell: UICollectionViewCell {
	static let identifier: String = "cellIdentifierGame"
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var labelName: UILabel!
	
	private let scheduler = QueueScheduler()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		#if os(tvOS)
		imageView.adjustsImageWhenAncestorFocused = true
		#endif
	}
	
	internal func bindViewModel(gameViewModel: GameViewModel) {
		imageView.image = nil
		labelName.text = gameViewModel.gameName.value
		if let url = NSURL(string: gameViewModel.gameImageURL.value) {
			imageView.af_setImageWithURL(url)
		}
	}
	
	private func gameImageSignalProducer(imageURL: String) -> SignalProducer<UIImage, NSError> {
		return SignalProducer {
			observer, dispoable in
			let data = NSData(contentsOfURL: NSURL(string: imageURL)!)
			guard let unwrappedData = data else {
				observer.sendFailed(NSError(domain: "0", code: 1, userInfo: nil))
				return
			}
			let image = UIImage(data: unwrappedData)
			guard let unwrappedImage = image else {
				observer.sendFailed(NSError(domain: "0", code: 1, userInfo: nil))
				return
			}
			observer.sendNext(unwrappedImage)
			observer.sendCompleted()
		}
	}
}
