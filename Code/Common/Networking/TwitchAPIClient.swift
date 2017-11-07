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
import Alamofire
import ReactiveSwift
import Result

final class TwitchAPIClient {

	static let sharedInstance: TwitchAPIClient = TwitchAPIClient()

	fileprivate var manager: SessionManager = {
		let sessionConfiguration = URLSessionConfiguration.default
		sessionConfiguration.timeoutIntervalForRequest = 10
		sessionConfiguration.httpAdditionalHeaders = ["Accept":"application/vnd.twitchtv.v3+json"]
		return Alamofire.SessionManager(configuration: sessionConfiguration)
	}()

	func request<T: Decodable>(_ urlString: String) -> SignalProducer<T, AnyError> {
		return SignalProducer { [unowned self] (observer, disposable) in
			let request = self.manager.request(urlString, method: .get, headers: ["Client-ID": Constants.clientId])
			print(request.debugDescription)
			request.validate().responseJSON { response in
				if case .failure(let error) = response.result {
					parseError(response.data, AnyError(error), observer)
				} else {
					parse(response.data!, observer)
				}
			}
			disposable.observeEnded {
				request.cancel()
			}
		}
	}

	func request<T: Decodable>(_ route: TwitchRouter) -> SignalProducer<T, AnyError> {
		return SignalProducer { [unowned self] (observer, disposable) in
			let request = self.manager.request(
				route.URLString,
				method: route.method,
				parameters: route.pathAndParams.parameters,
				encoding: URLEncoding.queryString,
				headers: ["Client-ID": Constants.clientId])
			print(request.debugDescription)
			request.validate().responseJSON { response in
				if case .failure(let error) = response.result {
					parseError(response.data, AnyError(error), observer)
				} else {
					parse(response.data!, observer)
				}
			}
			disposable.observeEnded {
				request.cancel()
			}
		}.observe(on: UIScheduler())
	}

	fileprivate func accessTokenForChannel(_ channelName: String) -> SignalProducer<AccessToken, AnyError> {
		return request(TwitchRouter.accessToken(channelName: channelName))
	}

	func m3u8URLForChannel(_ channelName: String) -> SignalProducer<String, AnyError> {
		return accessTokenForChannel(channelName)
			.map { return "http://usher.justin.tv/api/channel/hls/\(channelName)?allow_source=true&token=\($0.token)&sig=\($0.sig)" }
	}

	func getTopGames(_ page: Int) -> SignalProducer<TopGamesResponse, AnyError> {
		return request(TwitchRouter.gamesTop(page: page))
	}
}

private func parseError<T: Decodable> (_ data: Data?, _ error: AnyError, _ sink: Signal<T, AnyError>.Observer) {
	guard let data = data else {
		sink.send(error: error)
		return
	}
	do {
		let error = try JSONDecoder().decode(TwitchError.self, from: data)
		sink.send(error: AnyError(error))
	} catch _ {
		sink.send(error: error)
	}
}

private func parse<T: Decodable> (_ data: Data, _ sink: Signal<T, AnyError>.Observer) {
	do {
		let result: T = try JSONDecoder().decode(T.self, from: data)
		sink.send(value: result)
		sink.sendCompleted()
	} catch {
		sink.send(error: AnyError(error))
	}
}
