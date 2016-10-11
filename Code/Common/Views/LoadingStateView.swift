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

final class LoadingStateView: NibDesignable {
	var retry: (() -> ())? = nil
	
	let loadingState = MutableProperty<LoadingState<NSError>>(.Loading)
	let isEmpty = MutableProperty(false)
	
	fileprivate let disposable = CompositeDisposable()
	
	@IBInspectable var emptyImage: UIImage? = UIImage(named: "No-Search-Results") { didSet { updateEmptyImage() } }
	@IBInspectable var emptyText: String = "NOTHING HERE" { didSet { updateLabels() } }
	@IBInspectable var errorText: String? = nil { didSet { errorLabel.text = errorText } }
	@IBInspectable var textColor: UIColor? = UIColor.lightGray

  /// A view holding the content
	@IBOutlet var contentView: UIView!
	@IBOutlet var emptyView: UIView!
	@IBOutlet var emptyImageView: UIImageView!
	@IBOutlet var emptyLabel: UILabel!
	@IBOutlet var loadingView: UIView!
	@IBOutlet var loadingIndicator: UIActivityIndicatorView!
	@IBOutlet var errorView: UIView!
	@IBOutlet var errorLabel: UILabel!
	@IBOutlet var errorTitleLabel: UILabel!
	@IBOutlet var retryButton: UIButton!
	
	@IBAction func retry(_ button: UIButton) {
		retry?()
	}
	
	fileprivate func updateErrorMessage(_ error: NSError) {
		errorLabel.text = errorText ?? error.localizedDescription
	}
	
	fileprivate func updateEmptyImage() {
		emptyImageView.image = emptyImage
	}
	fileprivate func updateLabels() {
		emptyLabel.text = emptyText
		emptyLabel.textColor = textColor
		errorLabel.textColor = textColor
		errorTitleLabel.textColor = textColor
//		retryButton.setTitleColor(textColor, forState: .Normal)
	}
	
	func updatedState(_ loadingState: LoadingState<NSError>, isContentEmpty: Bool) {
		var isEmpty = false
		var isError = false
		var isLoading = false
		switch (loadingState, isContentEmpty) {
		case (.default, true):
			isEmpty = true
		case (.Loading, true):
			isLoading = true
		case (.failed(let error), true):
			isError = true
			updateErrorMessage(error)
		case (.failed(_), false):
			print("error loading more stuff")
		default:
			break
		}
		loadingView.isHidden = !isLoading
		if isLoading {
			loadingIndicator.startAnimating()
		} else {
			loadingIndicator.stopAnimating()
		}
		errorView.isHidden = !isError
		emptyView.isHidden = !isEmpty
		contentView.isHidden = isContentEmpty
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		updateEmptyImage()
		updateLabels()
		disposable += SignalProducer.combineLatest(loadingState.producer, isEmpty.producer).startWithValues(updatedState)
	}
	
	deinit {
		disposable.dispose()
	}
}
