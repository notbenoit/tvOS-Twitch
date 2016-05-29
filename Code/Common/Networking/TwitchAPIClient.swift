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
import ReactiveCocoa
import JSONParsing

final class TwitchAPIClient {

	static let sharedInstance: TwitchAPIClient = TwitchAPIClient()

	private var manager: Manager = {
		let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
		sessionConfiguration.timeoutIntervalForRequest = 10
		sessionConfiguration.HTTPAdditionalHeaders = ["Accept":"application/vnd.twitchtv.v3+json"]
		return Alamofire.Manager(configuration: sessionConfiguration)
	}()

	func request<T: JSONParsing>(urlString: String) -> SignalProducer<T, NSError> {
		return SignalProducer { [unowned self] (observer, disposable) in
			guard let url = NSURL(string: urlString) else {
				observer.sendFailed(NSError(domain: "com.twitch", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknow URL format"]))
				return
			}
			let request = self.manager.request(.GET, url)
			print(request.debugDescription)
			request.responseJSON { response in
				if case Result.Failure(let error) = response.result {
					parseError(response.data, error, observer)
				} else {
					parse(response.result.value, observer)
				}
			}
			disposable.addDisposable {
				request.cancel()
			}
		}
	}

	func request<T: JSONParsing>(route: TwitchRouter) -> SignalProducer<T, NSError> {
		return SignalProducer { [unowned self] (observer, disposable) in
			let request = self.manager.request(route)
			print(request.debugDescription)
			request.validate().responseJSON { response in
				if case Result.Failure(let error) = response.result {
					parseError(response.data, error, observer)
				} else {
					parse(response.result.value, observer)
				}
			}
			disposable.addDisposable {
				request.cancel()
			}
		}
	}

	private func accessTokenForChannel(channelName: String) -> SignalProducer<AccessToken, NSError> {
		return request(.AccessToken(channelName: channelName))
	}

	private func m3u8URLForChannel(channelName: String, accessToken: AccessToken) -> SignalProducer<String, NSError> {
		return SignalProducer {
			observer, disposable in
			let urlString = "http://usher.justin.tv/api/channel/hls/\(channelName)?allow_source=true&token=\(accessToken.token)&sig=\(accessToken.sig)"
			observer.sendNext(urlString)
			observer.sendCompleted()
		}
	}

	func m3u8URLForChannel(channelName: String) -> SignalProducer<String, NSError> {
		return accessTokenForChannel(channelName).flatMap(.Latest) {
			return self.m3u8URLForChannel(channelName, accessToken: $0)
		}
	}

	func getTopGames(page: Int) -> SignalProducer<TopGamesResponse, NSError> {
		return request(TwitchRouter.GamesTop(page: page))
	}

	func searchGames(page: Int) -> SignalProducer<TopGamesResponse, NSError> {
		return request(TwitchRouter.GamesTop(page: page))
	}

//	func searchGames(query: String) -> SignalProducer<ListResponse<Game>, NSError> {
//		return request(TwitchRouter.SearchGames(query: query), resultPath: "games")
//			.map { (result: (items: [Game], count: Int)) in
//				ListResponse(objects: result.items, count: result.count)
//		}
//	}

	func streamForGame(gameName: String?, page: Int) -> SignalProducer<StreamsResponse, NSError> {
		return request(TwitchRouter.Streams(gameName: gameName, page: page))
	}
}

private func parseError<T: JSONParsing> (data: NSData?, _ error: NSError, _ sink: Observer<T, NSError>) {
	guard let data = data else {
		sink.sendFailed(error)
		return
	}
	do {
		let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
		let error = try TwitchError.parse(JSON(json))
		sink.sendFailed(error.toError)
	} catch _ {
		sink.sendFailed(error)
	}
}

private func parse<T: JSONParsing> (object: AnyObject?, _ sink: Observer<T, NSError>) {
	let errorDomain = "JSONParsing"
	do {
		let result = try T.parse(JSON(object))
		sink.sendNext(result)
		sink.sendCompleted()
	} catch JSON.Error.NoValue(let json) {
		let desc = "JSON value not found at key path \(json.pathFromRoot)"
		let error = NSError(domain: errorDomain,
		                    code: (-2),
		                    userInfo: [NSLocalizedDescriptionKey: desc])
		sink.sendFailed(error)
	} catch JSON.Error.TypeMismatch(let json) {
		let desc = "JSON value type mismatch at key path \(json.pathFromRoot)"
		let error = NSError(domain: errorDomain,
		                    code: (-3),
		                    userInfo: [NSLocalizedDescriptionKey: desc])
		sink.sendFailed(error)
	} catch _ {
		let desc = "Unknown error while parsing server response"
		let error = NSError(domain: errorDomain,
		                    code: (-1),
		                    userInfo: [NSLocalizedDescriptionKey: desc])
		sink.sendFailed(error)
	}
}
