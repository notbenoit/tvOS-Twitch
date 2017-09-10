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
import WebImage
import DataSource

final class GameCell: CollectionViewCell {
	static let identifier: String = "cellIdentifierGame"
	static let nib: UINib = UINib(nibName: "GameCell", bundle: nil)
	
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var labelName: UILabel!
	
	fileprivate let textDefaultFont = UIFont.boldSystemFont(ofSize: 22)
	fileprivate let textDefaultColor = UIColor.lightGray

	override func prepareForReuse() {
		imageView.image = nil
		labelName.text = nil
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		imageView.adjustsImageWhenAncestorFocused = true
		self.labelName.font = textDefaultFont
		self.labelName.textColor = textDefaultColor
		self.labelName.shadowOffset = CGSize(width: 0, height: 1)
		self.backgroundColor = UIColor.twitchLightColor()
		
		reactive.configure <~ cellModel.producer
			.map { $0 as? GameCellViewModel }
			.skipNil()
	}
	
	fileprivate func configure(with item: GameCellViewModel) {
		labelName.text = item.gameName
		if let url = URL(string: item.gameImageURL) {
			imageView.sd_setImage(with: url)
		}
	}
	
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		let transform = isFocused ? CGAffineTransform(translationX: 0, y: 35) : CGAffineTransform.identity
		let labelShadowColor = isFocused ? UIColor.darkGray : UIColor.clear
		let labelTextColor = isFocused ? UIColor.white : textDefaultColor
		coordinator.addCoordinatedAnimations({
			self.labelName.transform = transform
			self.labelName.shadowColor = labelShadowColor
			self.labelName.textColor = labelTextColor
		}, completion: nil)
	}
}

extension Reactive where Base: GameCell {
	var configure: BindingTarget<GameCellViewModel> {
		return makeBindingTarget { $0.configure(with: $1) }
	}
}
