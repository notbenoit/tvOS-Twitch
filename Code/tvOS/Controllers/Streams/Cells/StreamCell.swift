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
import WebImage
import DataSource

class StreamCell: CollectionViewCell {
	static let identifier: String = "cellIdentifierStream"
	static let nib: UINib = UINib(nibName: "StreamCell", bundle: nil)
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var placeholder: UIImageView!
	@IBOutlet weak var streamNameLabel: UILabel!
	@IBOutlet weak var viewersCountLabel: UILabel!
	
	private let defaultTextColor = UIColor.lightGrayColor()
	private let focusedTextColor = UIColor.whiteColor()
	private let defaultStreamFont = UIFont.boldSystemFontOfSize(22)
	private let defaultViewersFont = UIFont.systemFontOfSize(22)
	
	override func prepareForReuse() {
		super.prepareForReuse()
		imageView.image = nil
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		imageView.layer.borderWidth = 1.0
		imageView.layer.borderColor = UIColor.clearColor().CGColor
		placeholder.image = placeholder.image?.imageWithRenderingMode(.AlwaysTemplate)
		placeholder.tintColor = UIColor.twitchDarkColor()
		streamNameLabel.textColor = defaultTextColor
		viewersCountLabel.textColor = defaultTextColor
		streamNameLabel.font = defaultStreamFont
		viewersCountLabel.font = defaultViewersFont
		
		disposable += cellModel.producer
			.map { $0 as? StreamViewModel }
			.ignoreNil()
			.start(self, StreamCell.configureWithItem)
	}
	
	private func configureWithItem(item: StreamViewModel) {
		streamNameLabel.text = item.streamTitle
		viewersCountLabel.text = item.viewersCount
		if let url = NSURL(string: item.streamImageURL) {
			imageView.sd_setImageWithURL(url)
		}
	}
	
	override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
		let color = self.focused ? focusedTextColor : defaultTextColor
		let borderColor = self.focused ? UIColor.whiteColor().CGColor : UIColor.clearColor().CGColor
		if focused {
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
