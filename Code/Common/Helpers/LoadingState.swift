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

enum LoadingState<E: Error> {
	case `default`
	case Loading
	case failed(error: E)
	
	var loading: Bool {
		if case .Loading = self {
			return true
		}
		return false
	}
	
	var error: E? {
		if case .failed(let error) = self {
			return error
		}
		return nil
	}
}

extension Action {
	var loadingState: SignalProducer<LoadingState<Error>, NoError> {
		// Produces .Loading when Loading
		let loadingProducer = self.isExecuting.producer
			.filter { $0 }
			.map { _ in LoadingState<Error>.Loading }
		// Produces error, or default if no error
		let errorProducer = self.events.map {
			(event: Event<Output, Error>) -> LoadingState<Error> in
			switch event {
			case .failed(let error):
				return LoadingState<Error>.failed(error: error)
			default:
				return LoadingState<Error>.default
			}
		}
		return loadingProducer.lift { Signal<LoadingState<Error>, NoError>.merge([$0, errorProducer]) }
	}
}
