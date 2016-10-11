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

extension UIViewController {
	func presentDefaultError(_ error: NSError) {
		let alert = UIAlertController(title: NSLocalizedString("An error occured", comment: ""), message: nil, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}

extension UIView {
	func addAndFitSubview(_ view: UIView) {
		view.translatesAutoresizingMaskIntoConstraints = false
		view.frame = self.bounds
		self.addSubview(view)
		let views = ["view": view]
		let options = NSLayoutFormatOptions(rawValue: 0)
		self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: options, metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: options, metrics: nil, views: views))
	}
}

extension UITableView {
	func deselectAllRows(_ animated: Bool) {
		if let indexPaths = self.indexPathsForSelectedRows {
			for indexPath in indexPaths {
				self.deselectRow(at: indexPath, animated: animated)
			}
		}
	}
}
