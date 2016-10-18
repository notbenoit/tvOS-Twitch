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
import ReactiveSwift
import Result

func scheduleAfter(_ timeInterval: TimeInterval, action: @escaping ()->()) -> Disposable? {
	let scheduler = QueueScheduler.main
	let date = scheduler.currentDate.addingTimeInterval(timeInterval)
	return scheduler.schedule(after: date, action: action)
}

extension SignalProtocol {
	
	func mergeWith(_ signal2: Signal<Value, Error>) -> Signal<Value, Error> {
		return Signal { observer in
			let disposable = CompositeDisposable()
			disposable += self.observe(observer)
			disposable += signal2.observe(observer)
			return disposable
		}
	}
	
}

extension SignalProducerProtocol {
	
	func ignoreError() -> SignalProducer<Value, NoError> {
		return self.flatMapError { _ in
			SignalProducer<Value, NoError>.empty
		}
	}
	
	func delayStart(_ interval: TimeInterval, onScheduler scheduler: DateSchedulerProtocol)
		-> ReactiveSwift.SignalProducer<Value, Error>
	{
		return SignalProducer<(), Error>(value: ())
			.delay(interval, on: scheduler)
			.flatMap(.latest) { _ in self.producer }
	}
	
	func start<T: AnyObject>(_ object: T, function: @escaping (T) -> (Value) -> Void) -> Disposable {
		return startWithResult { [weak object] in
			guard let object = object, let value = try? $0.dematerialize() else { return }
			function(object)(value)
		}
	}
}

extension SignalProducerProtocol where Error == NoError {
	
	func chain<U>(_ transform: @escaping (Value) -> Signal<U, NoError>) -> SignalProducer<U, NoError> {
		return flatMap(.latest, transform: transform)
	}
	
	func chain<U>(_ transform: @escaping (Value) -> SignalProducer<U, NoError>) -> SignalProducer<U, NoError> {
		return flatMap(.latest, transform: transform)
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
