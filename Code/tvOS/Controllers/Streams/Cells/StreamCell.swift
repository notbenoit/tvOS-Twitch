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

final class StreamCell: CollectionViewCell {
	static let identifier: String = "cellIdentifierStream"
	static let nib: UINib = UINib(nibName: "StreamCell", bundle: nil)
	
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var placeholder: UIImageView!
	@IBOutlet var streamNameLabel: UILabel!
	@IBOutlet var viewersCountLabel: UILabel!
	
	fileprivate let defaultTextColor = UIColor.lightGray
	fileprivate let focusedTextColor = UIColor.white
	fileprivate let defaultStreamFont = UIFont.boldSystemFont(ofSize: 22)
	fileprivate let defaultViewersFont = UIFont.systemFont(ofSize: 22)
	
	override func prepareForReuse() {
		super.prepareForReuse()
		imageView.image = nil
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		imageView.layer.borderWidth = 1.0
		imageView.layer.borderColor = UIColor.clear.cgColor
		placeholder.image = placeholder.image?.withRenderingMode(.alwaysTemplate)
		placeholder.tintColor = .twitchDark
		streamNameLabel.textColor = defaultTextColor
		viewersCountLabel.textColor = defaultTextColor
		streamNameLabel.font = defaultStreamFont
		viewersCountLabel.font = defaultViewersFont
		
		reactive.configure <~ cellModel.producer
			.map { $0 as? StreamViewModel }
			.skipNil()
	}
	
	fileprivate func configure(withItem item: StreamViewModel) {
		streamNameLabel.text = item.streamTitle
		viewersCountLabel.text = item.viewersCount
		if let url = URL(string: item.streamImageURL) {
			imageView.sd_setImage(with: url)
		}
	}
	
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		let color = isFocused ? focusedTextColor : defaultTextColor
		let borderColor = isFocused ? UIColor.white.cgColor : UIColor.clear.cgColor
		if isFocused {
			applyMotionEffectForX(10, y: 10)
		} else {
			removeMotionEffects()
		}
		coordinator.addCoordinatedAnimations({
			[weak self] in
			self?.viewersCountLabel.textColor = color
			self?.streamNameLabel.textColor = color
			self?.imageView.layer.borderColor = borderColor
			}, completion: nil)
	}
}

extension Reactive where Base: StreamCell {

	var configure: BindingTarget<StreamViewModel> {
		return makeBindingTarget { $0.configure(withItem: $1) }
	}

}
