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
import Result

final class LoadingStateView: NibDesignable {
	var retry: (() -> ())? = nil
	
	fileprivate let loadingState = MutableProperty<LoadingState<AnyError>>(.loading)
	fileprivate let isEmpty = MutableProperty(false)
	
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
	
	fileprivate func updateErrorMessage(_ error: AnyError) {
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
	}
	
	func updatedState(_ loadingState: LoadingState<AnyError>, isContentEmpty: Bool) {
		var isEmpty = false
		var isError = false
		var isLoading = false
		switch (loadingState, isContentEmpty) {
		case (.default, true):
			isEmpty = true
		case (.loading, true):
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
		loadingState.combineLatest(with: isEmpty)
			.producer
			.startWithValues { [weak self] in
				self?.updatedState($0.0, isContentEmpty: $0.1)
		}
	}

}

extension Reactive where Base: LoadingStateView {

	var loadingState: BindingTarget<LoadingState<AnyError>> {
		return makeBindingTarget { $0.loadingState.value = $1 }
	}

	var isEmpty: BindingTarget<Bool> {
		return makeBindingTarget { $0.isEmpty.value = $1 }
	}

}
