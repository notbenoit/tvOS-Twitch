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
import JSONParsing

final class TwitchAPIClient {

	static let sharedInstance: TwitchAPIClient = TwitchAPIClient()

	fileprivate var manager: SessionManager = {
		let sessionConfiguration = URLSessionConfiguration.default
		sessionConfiguration.timeoutIntervalForRequest = 10
		sessionConfiguration.httpAdditionalHeaders = ["Accept":"application/vnd.twitchtv.v3+json"]
		return Alamofire.SessionManager(configuration: sessionConfiguration)
	}()

	func request<T: JSONParsing>(_ urlString: String) -> SignalProducer<T, NSError> {
		return SignalProducer { [unowned self] (observer, disposable) in
			let request = self.manager.request(urlString, method: .get, headers: ["Client-ID": Constants.clientId])
			print(request.debugDescription)
			request.responseJSON { response in
				if case .failure(let error as NSError) = response.result {
					parseError(response.data, error, observer)
				} else {
					parse(response.result.value, observer)
				}
			}
			disposable.observeEnded {
				request.cancel()
			}
		}
	}

	func request<T: JSONParsing>(_ route: TwitchRouter) -> SignalProducer<T, NSError> {
		return SignalProducer { [unowned self] (observer, disposable) in
			let request = self.manager.request(
				route.URLString,
				method: route.method,
				parameters: route.pathAndParams.parameters,
				encoding: URLEncoding.queryString,
				headers: ["Client-ID": Constants.clientId])
			print(request.debugDescription)
			request.validate().responseJSON { response in
				if case .failure(let error as NSError) = response.result {
					parseError(response.data, error, observer)
				} else {
					parse(response.result.value, observer)
				}
			}
			disposable.observeEnded {
				request.cancel()
			}
		}.observe(on: UIScheduler())
	}

	fileprivate func accessTokenForChannel(_ channelName: String) -> SignalProducer<AccessToken, NSError> {
		return request(TwitchRouter.accessToken(channelName: channelName))
	}

	func m3u8URLForChannel(_ channelName: String) -> SignalProducer<String, NSError> {
		return accessTokenForChannel(channelName)
			.map { return "http://usher.justin.tv/api/channel/hls/\(channelName)?allow_source=true&token=\($0.token)&sig=\($0.sig)" }
	}

	func getTopGames(_ page: Int) -> SignalProducer<TopGamesResponse, NSError> {
		return request(TwitchRouter.gamesTop(page: page))
	}
}

private func parseError<T: JSONParsing> (_ data: Data?, _ error: NSError, _ sink: Signal<T, NSError>.Observer) {
	guard let data = data else {
		sink.send(error: error)
		return
	}
	do {
		let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
		let error = try TwitchError.parse(JSON(json as AnyObject))
		sink.send(error: error.toError)
	} catch _ {
		sink.send(error: error)
	}
}

private func parse<T: JSONParsing> (_ object: Any?, _ sink: Signal<T, NSError>.Observer) {
	let errorDomain = "JSONParsing"
	do {
		let result = try T.parse(JSON(object as? NSDictionary))
		sink.send(value: result)
		sink.sendCompleted()
	} catch JSON.Error.noValue(let json) {
		let desc = "JSON value not found at key path \(json.pathFromRoot)"
		let error = NSError(domain: errorDomain,
		                    code: (-2),
		                    userInfo: [NSLocalizedDescriptionKey: desc])
		sink.send(error: error)
	} catch JSON.Error.typeMismatch(let json) {
		let desc = "JSON value type mismatch at key path \(json.pathFromRoot)"
		let error = NSError(domain: errorDomain,
		                    code: (-3),
		                    userInfo: [NSLocalizedDescriptionKey: desc])
		sink.send(error: error)
	} catch _ {
		let desc = "Unknown error while parsing server response"
		let error = NSError(domain: errorDomain,
		                    code: (-1),
		                    userInfo: [NSLocalizedDescriptionKey: desc])
		sink.send(error: error)
	}
}
