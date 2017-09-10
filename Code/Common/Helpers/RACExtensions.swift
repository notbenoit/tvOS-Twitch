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

extension SignalProducer where Error == NoError {
	
	func chain<U>(_ transform: @escaping (Value) -> Signal<U, NoError>) -> SignalProducer<U, NoError> {
		return flatMap(.latest, transform)
	}
	
	func chain<U>(_ transform: @escaping (Value) -> SignalProducer<U, NoError>) -> SignalProducer<U, NoError> {
		return flatMap(.latest, transform)
	}
	
	func chain<P: PropertyProtocol>(_ transform: @escaping (Value) -> P) -> SignalProducer<P.Value, NoError> {
		return flatMap(.latest) { transform($0).producer }
	}
	
	func chain<U>(_ transform: @escaping (Value) -> Signal<U, NoError>?) -> SignalProducer<U, NoError> {
		return flatMap(.latest) { transform($0) ?? Signal<U, NoError>.never }
	}
	
	func chain<U>(_ transform: @escaping (Value) -> SignalProducer<U, NoError>?) -> SignalProducer<U, NoError> {
		return flatMap(.latest) { transform($0) ?? SignalProducer<U, NoError>.empty }
	}
	
	func chain<P: PropertyProtocol>(_ transform: @escaping (Value) -> P?) -> SignalProducer<P.Value, NoError> {
		return flatMap(.latest) { transform($0)?.producer ?? SignalProducer<P.Value, NoError>.empty }
	}
	
}

extension PropertyProtocol {
	
	func chain<U>(_ transform: @escaping (Value) -> Signal<U, NoError>) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}
	
	func chain<U>(_ transform: @escaping (Value) -> SignalProducer<U, NoError>) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}
	
	func chain<P: PropertyProtocol>(_ transform: @escaping (Value) -> P) -> SignalProducer<P.Value, NoError> {
		return producer.chain(transform)
	}
	
	func chain<U>(_ transform: @escaping (Value) -> Signal<U, NoError>?) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}
	
	func chain<U>(_ transform: @escaping (Value) -> SignalProducer<U, NoError>?) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}
	
	func chain<P: PropertyProtocol>(_ transform: @escaping (Value) -> P?) -> SignalProducer<P.Value, NoError> {
		return producer.chain(transform)
	}
	
}

#if os(iOS)
extension Reactive where Base: UIApplication {
	var isNetworkIndicatorVisible: BindingTarget<Bool> {
		return target { $0.0.isNetworkActivityIndicatorVisible = $0.1 }
	}
}
#endif
