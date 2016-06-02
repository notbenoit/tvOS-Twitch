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
import Result

func scheduleAfter(timeInterval: NSTimeInterval, action: ()->()) -> Disposable? {
	let scheduler = QueueScheduler.mainQueueScheduler
	let date = scheduler.currentDate.dateByAddingTimeInterval(timeInterval)
	return scheduler.scheduleAfter(date, action: action)
}

extension SignalType {
	
	func mergeWith(signal2: Signal<Value, Error>) -> Signal<Value, Error> {
		return Signal { observer in
			let disposable = CompositeDisposable()
			disposable += self.observe(observer)
			disposable += signal2.observe(observer)
			return disposable
		}
	}
	
}

extension SignalProducerType {
	@warn_unused_result(message="Did you forget to call `start` on the producer?")
	func ignoreError() -> SignalProducer<Value, NoError> {
		return self.flatMapError { _ in
			SignalProducer<Value, NoError>.empty
		}
	}
	
	@warn_unused_result(message="Did you forget to call `start` on the producer?")
	func delayStart(interval: NSTimeInterval, onScheduler scheduler: DateSchedulerType)
		-> ReactiveCocoa.SignalProducer<Value, Error>
	{
		return SignalProducer<(), Error>(value: ())
			.delay(interval, onScheduler: scheduler)
			.flatMap(.Latest) { _ in self.producer }
	}
}

extension SignalProducerType where Error == NoError {
	
	func chain<U>(transform: Value -> Signal<U, NoError>) -> SignalProducer<U, NoError> {
		return flatMap(.Latest, transform: transform)
	}
	
	func chain<U>(transform: Value -> SignalProducer<U, NoError>) -> SignalProducer<U, NoError> {
		return flatMap(.Latest, transform: transform)
	}
	
	func chain<P: PropertyType>(transform: Value -> P) -> SignalProducer<P.Value, NoError> {
		return flatMap(.Latest) { transform($0).producer }
	}
	
	func chain<U>(transform: Value -> Signal<U, NoError>?) -> SignalProducer<U, NoError> {
		return flatMap(.Latest) { transform($0) ?? Signal<U, NoError>.never }
	}
	
	func chain<U>(transform: Value -> SignalProducer<U, NoError>?) -> SignalProducer<U, NoError> {
		return flatMap(.Latest) { transform($0) ?? SignalProducer<U, NoError>.empty }
	}
	
	func chain<P: PropertyType>(transform: Value -> P?) -> SignalProducer<P.Value, NoError> {
		return flatMap(.Latest) { transform($0)?.producer ?? SignalProducer<P.Value, NoError>.empty }
	}
	
}

extension PropertyType {
	
	func chain<U>(transform: Value -> Signal<U, NoError>) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}
	
	func chain<U>(transform: Value -> SignalProducer<U, NoError>) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}
	
	func chain<P: PropertyType>(transform: Value -> P) -> SignalProducer<P.Value, NoError> {
		return producer.chain(transform)
	}
	
	func chain<U>(transform: Value -> Signal<U, NoError>?) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}
	
	func chain<U>(transform: Value -> SignalProducer<U, NoError>?) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}
	
	func chain<P: PropertyType>(transform: Value -> P?) -> SignalProducer<P.Value, NoError> {
		return producer.chain(transform)
	}
	
}