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

protocol NibDesignableType: NSObjectProtocol {
	var nibName: String { get }
	var containerView: UIView { get }
}

extension NibDesignableType {
	// MARK: - Nib loading
	
	/**
	Called to load the nib in setupNib().
	- returns: UIView instance loaded from a nib file.
	*/
	func loadNib() -> UIView {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: self.nibName, bundle: bundle)
		return nib.instantiate(withOwner: self, options: nil)[0] as! UIView
	}
	
	// MARK: - Nib loading
	
	/**
	Called in init(frame:) and init(aDecoder:) to load the nib and add it as a subview.
	*/
	fileprivate func setupNib() {
		let view = self.loadNib()
		self.containerView.addAndFitSubview(view)
	}
}

extension UIView: NibDesignableType {
	var containerView: UIView { return self }
	var nibName: String { return type(of: self).description().components(separatedBy: ".").last! }
}

/// This class only exists in order to be subclassed.
class NibDesignable: UIView {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupNib()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupNib()
	}
}

/// This class only exists in order to be subclassed.
class	ControlNibDesignable: UIControl {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupNib()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupNib()
	}
}

