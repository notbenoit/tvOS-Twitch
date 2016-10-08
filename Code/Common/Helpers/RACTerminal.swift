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
import ReactiveCocoa
import Result

public final class Terminal<Value> {
	
	public let disposable: CompositeDisposable
	public let setter: ((Value) -> Void)
	
	public init(disposable: CompositeDisposable, setter: @escaping (Value) -> Void) {
		self.disposable = disposable
		self.setter = setter
	}
	
	public convenience init<Object: NSObject>(_ object: Object, setter: @escaping (Object, Value) -> Void) {
		let disposable = CompositeDisposable()
		object.rac_lifetime.ended.observeCompleted {
			disposable.dispose()
		}
		self.init(disposable: disposable) {
			[weak object] value in
			if let object = object {
				setter(object, value)
			}
		}
	}
	
}

@discardableResult public func <~ <Value> (terminal: Terminal<Value>?, producer: Signal<Value, NoError>) -> Disposable? {
	guard let terminal = terminal else { return nil }
	let disposable = producer.observeValues(terminal.setter)
	terminal.disposable += disposable
	return disposable
}

@discardableResult public func <~ <Value> (terminal: Terminal<Value>?, producer: SignalProducer<Value, NoError>) -> Disposable? {
	guard let terminal = terminal else { return nil }
	let disposable = producer.startWithValues(terminal.setter)
	terminal.disposable += disposable
	return disposable
}

@discardableResult public func <~ <P: PropertyProtocol> (terminal: Terminal<P.Value>?, property: P) -> Disposable? {
	guard let terminal = terminal else { return nil }
	return terminal <~ property.producer
}

@discardableResult public func <~ <Value> (terminal: Terminal<Value?>?, producer: Signal<Value, NoError>) -> Disposable? {
	guard let terminal = terminal else { return nil }
	let disposable = producer.observeValues(terminal.setter)
	terminal.disposable += disposable
	return disposable
}

@discardableResult public func <~ <Value> (terminal: Terminal<Value?>?, producer: SignalProducer<Value, NoError>) -> Disposable? {
	guard let terminal = terminal else { return nil }
	let disposable = producer.startWithValues(terminal.setter)
	terminal.disposable += disposable
	return disposable
}

@discardableResult public func <~ <P: PropertyProtocol> (terminal: Terminal<P.Value?>?, property: P) -> Disposable? {
	guard let terminal = terminal else { return nil }
	return terminal <~ property.producer
}


extension UIViewController {
	
	var rac_title: Terminal<String?> {
		return Terminal(self) { $0.title = $1 }
	}
	
}

extension UIView {
	
	var rac_alphaLayer: Terminal<Float> {
		return Terminal(self) {	$0.layer.opacity = $1	}
	}
	
	var rac_hidden: Terminal<Bool> {
		return Terminal(self) { $0.isHidden = $1 }
	}
	
	var rac_userInteractionEnabled: Terminal<Bool> {
		return Terminal(self) { $0.isUserInteractionEnabled = $1 }
	}
	
	var rac_alpha: Terminal<CGFloat> {
		return Terminal(self) { $0.alpha = $1 }
	}
	
	var rac_backgroundColor: Terminal<UIColor> {
		return Terminal(self) { $0.backgroundColor = $1	}
	}
	
	var rac_tintColor: Terminal<UIColor> {
		return Terminal(self) { $0.tintColor = $1 }
	}
}

extension UIImageView {
	var rac_image: Terminal<UIImage?> {
		return Terminal(self) { $0.image = $1 }
	}
}

extension UILabel {
	
	var rac_text: Terminal<String?> {
		return Terminal(self) { $0.text = $1 }
	}
	
	var rac_attributedString: Terminal<NSAttributedString?> {
		return Terminal(self) { $0.attributedText = $1 }
	}
	
	var rac_textColor: Terminal<UIColor?> {
		return Terminal(self) { $0.textColor = $1 }
	}
	
}

extension UIButton {
	
	var rac_enabled: Terminal<Bool> {
		return Terminal(self) { $0.isEnabled = $1 }
	}
	var rac_selected: Terminal<Bool> {
		return Terminal(self) { $0.isSelected = $1 }
	}
	
	var rac_title: Terminal<String> {
		return Terminal(self) {
			object, title in
			UIView.performWithoutAnimation {
				object.setTitle(title, for: .normal)
				object.layoutIfNeeded()
			}
		}
	}
	
	var rac_attributedTitle: Terminal<NSAttributedString> {
		return Terminal(self) {
			object, title in
			UIView.performWithoutAnimation {
				object.setAttributedTitle(title, for: .normal)
				object.layoutIfNeeded()
			}
		}
	}
	
	var rac_image: Terminal<UIImage?> {
		return Terminal(self) { $0.setImage($1, for: .normal) }
	}
	
	var rac_textColor: Terminal<UIColor?> {
		return Terminal(self) { $0.setTitleColor($1, for: .normal) }
	}

}

extension UIBarButtonItem {
	
	var rac_enabled: Terminal<Bool> {
		return Terminal(self) { $0.isEnabled = $1 }
	}
	
	var rac_text: Terminal<String?> {
		return Terminal(self) { $0.title = $1 }
	}
	
}

extension UISegmentedControl {
	
	var rac_selectedSegment: Terminal<Int> {
		return Terminal(self) { $0.selectedSegmentIndex = $1 }
	}
	
}

extension UIApplication {
	#if os(iOS)
	var rac_networkIndicatorVisible: Terminal<Bool> {
		return Terminal(self) { $0.isNetworkActivityIndicatorVisible = $1 }
	}
	#endif
}
