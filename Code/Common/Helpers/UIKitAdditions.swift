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

struct AssociationKey {
	static var hidden: UInt8 = 1
	static var alpha: UInt8 = 2
	static var text: UInt8 = 3
}

// lazily creates a gettable associated property via the given factory
func lazyAssociatedProperty<T: AnyObject>(host: AnyObject, key: UnsafePointer<Void>, factory: ()->T) -> T {
	return objc_getAssociatedObject(host, key) as? T ?? {
		let associatedProperty = factory()
		objc_setAssociatedObject(host, key, associatedProperty, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
		return associatedProperty
  }()
}

func lazyMutableProperty<T>(host: AnyObject, key: UnsafePointer<Void>, setter: T -> (), getter: () -> T) -> MutableProperty<T> {
	return lazyAssociatedProperty(host, key: key) {
		let property = MutableProperty<T>(getter())
		property.producer.startWithNext {
			newValue in
			setter(newValue)
		}
		return property
	}
}

extension UIView {
	public var rac_alpha: MutableProperty<CGFloat> {
		return lazyMutableProperty(self, key: &AssociationKey.alpha, setter: { self.alpha = $0 }, getter: { self.alpha  })
	}
	
	public var rac_hidden: MutableProperty<Bool> {
		return lazyMutableProperty(self, key: &AssociationKey.hidden, setter: { self.hidden = $0 }, getter: { self.hidden  })
	}
}

extension UILabel {
	public var rac_text: MutableProperty<String> {
		return lazyMutableProperty(self, key: &AssociationKey.text, setter: { self.text = $0 }, getter: { self.text ?? "" })
	}
}

extension UITextField {
	public var rac_text: MutableProperty<String> {
		return lazyAssociatedProperty(self, key: &AssociationKey.text) {
			
			self.addTarget(self, action: "changed", forControlEvents: UIControlEvents.EditingChanged)
			
			let property = MutableProperty<String>(self.text ?? "")
			property.producer
				.startWithNext {
					newValue in
					self.text = newValue
			}
			return property
		}
	}
	
	func changed() {
		rac_text.value = self.text ?? ""
	}
}