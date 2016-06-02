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

import Foundation
import ReactiveCocoa

final class Terminal<Value> {
	
	let disposable: CompositeDisposable
	let setter: (Value -> Void)
	
	init(disposable: CompositeDisposable, setter: Value -> Void) {
		self.disposable = disposable
		self.setter = setter
	}
	
	convenience init(_ object: NSObject, setter: Value -> Void) {
		let disposable = CompositeDisposable()
		object.rac_deallocDisposable.addDisposable(RACDisposable {
			disposable.dispose()
			})
		self.init(disposable: disposable, setter: setter)
	}
	
}

func <~ <Value, Error: ErrorType>
	(terminal: Terminal<Value>, producer: SignalProducer<Value, Error>)
	-> Disposable
{
	let disposable = producer.startWithNext(terminal.setter)
	terminal.disposable += disposable
	return disposable
}

func <~ <P: PropertyType>
	(terminal: Terminal<P.Value>, property: P)
	-> Disposable
{
	return terminal <~ property.producer
}

func <~ <Value, Error: ErrorType>
	(terminal: Terminal<Value?>, producer: SignalProducer<Value, Error>)
	-> Disposable
{
	let disposable = producer.startWithNext(terminal.setter)
	terminal.disposable += disposable
	return disposable
}


extension UIViewController {
	
	var rac_title: Terminal<String?> {
		return Terminal(self) {
			[weak self] newValue in
			self?.title = newValue
		}
	}
	
}

extension UIView {
	
	var rac_alphaLayer: Terminal<Float> {
		return Terminal(self) {
			[weak self] newValue in
			self?.layer.opacity = newValue
		}
	}
	
	var rac_hidden: Terminal<Bool> {
		return Terminal(self) {
			[weak self] bool in
			self?.hidden = bool
		}
	}
	
	var rac_userInteractionEnabled: Terminal<Bool> {
		return Terminal(self) {
			[weak self] bool in
			self?.userInteractionEnabled = bool
		}
	}
	
	var rac_alpha: Terminal<CGFloat> {
		return Terminal(self) {
			[weak self] newValue in
			self?.alpha = newValue
		}
	}
	
	var rac_backgroundColor: Terminal<UIColor> {
		return Terminal(self) {
			[weak self] newValue in
			self?.backgroundColor = newValue
		}
	}
	
	var rac_tintColor: Terminal<UIColor> {
		return Terminal(self) {
			[weak self] newValue in
			self?.tintColor = newValue
		}
	}
}

extension UIImageView {
	var rac_image: Terminal<UIImage?> {
		return Terminal(self) {
			[weak self] image in
			self?.image = image
		}
	}
}

extension UILabel {
	
	var rac_text: Terminal<String?> {
		return Terminal(self) {
			[weak self] newValue in
			self?.text = newValue
		}
	}
	
	var rac_attributedString: Terminal<NSAttributedString?> {
		return Terminal(self) {
			[weak self] newValue in
			self?.attributedText = newValue
		}
	}
	
	var rac_textColor: Terminal<UIColor?> {
		return Terminal(self) {
			[weak self] newValue in
			self?.textColor = newValue
		}
	}
	
}

extension UIButton {
	
	var rac_enabled: Terminal<Bool> {
		return Terminal(self) {
			[weak self] bool in
			self?.enabled = bool
		}
	}
	var rac_selected: Terminal<Bool> {
		return Terminal(self) {
			[weak self] bool in
			self?.selected = bool
		}
	}
	
	var rac_title: Terminal<String> {
		return Terminal(self) {
			[weak self] title in
			UIView.performWithoutAnimation {
				self?.setTitle(title, forState: .Normal)
				self?.layoutIfNeeded()
			}
		}
	}
	
	var rac_attributedTitle: Terminal<NSAttributedString> {
		return Terminal(self) {
			[weak self] title in
			UIView.performWithoutAnimation {
				self?.setAttributedTitle(title, forState: .Normal)
				self?.layoutIfNeeded()
			}
		}
	}
	
	var rac_image: Terminal<UIImage?> {
		return Terminal(self) {
			[weak self] image in
			self?.setImage(image, forState: .Normal)
		}
	}
	
	var rac_textColor: Terminal<UIColor?> {
		return Terminal(self) {
			[weak self] newValue in
			self?.setTitleColor(newValue, forState: .Normal)
		}
	}

}

extension UIBarButtonItem {
	
	var rac_enabled: Terminal<Bool> {
		return Terminal(self) {
			[weak self] bool in
			self?.enabled = bool
		}
	}
	
	var rac_text: Terminal<String?> {
		return Terminal(self) {
			[weak self] newValue in
			self?.title = newValue
		}
	}
	
}

extension UISegmentedControl {
	
	var rac_selectedSegment: Terminal<Int> {
		return Terminal(self) {
			[weak self] selectedSegment in
			self?.selectedSegmentIndex = selectedSegment
		}
	}
	
}

extension UIApplication {
	#if os(iOS)
	var rac_networkIndicatorVisible: Terminal<Bool> {
		return Terminal(self) {
			[weak self] visible in
			self?.networkActivityIndicatorVisible = visible
		}
	}
	#endif
}
