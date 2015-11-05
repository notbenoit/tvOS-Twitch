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
import ObjectMapper

final class TwitchAPIClient {
	
	static let sharedInstance: TwitchAPIClient = TwitchAPIClient()
	
	private var manager: Manager = {
		let sessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.twitch.data")
		sessionConfiguration.HTTPAdditionalHeaders = ["Accept":"application/vnd.twitchtv.v3+json"]
		return Alamofire.Manager(configuration: sessionConfiguration)
	}()
	
	func request(route: TwitchRouter) -> SignalProducer<AnyObject?, NSError> {
		return SignalProducer { [unowned self] (observer, disposable) in
			let request = self.manager.request(route)
			request.validate()
			request.responseJSON { response in
				if case Result.Failure(let error) = response.result {
					observer.sendFailed(error)
				} else {
					observer.sendNext(response.result.value)
					observer.sendCompleted()
				}
			}
			disposable.addDisposable {
				request.cancel()
			}
		}
	}
	
	func request<T: Mappable>(route: TwitchRouter, resultPath: String = "top", countPath: String = "_total") -> SignalProducer<(items: [T], count: Int), NSError> {
		return request(route).map{ resultObject in
			guard let result = resultObject as? NSDictionary else {
				print("\(route.URLRequest.description) : Expecting dictionary of JSON objects, received something else: \(resultObject)")
				return ([], 0)
			}
			guard let resultArray = result.valueForKeyPath(resultPath) as? [[String:AnyObject]] else {
				print("\(route.URLRequest.description) : Dictionary \(result) doesn't contain key path \(resultPath) for results array")
				return ([], 0)
			}
			let count: Int
			if let resultCount = result.valueForKeyPath(countPath) as? Int {
				count = resultCount
			} else {
				print("\(route.URLRequest.description) : Keypath for count \(countPath) doesn't exist in \(result), using result array count \(resultArray.count)")
				// In case the dictionary doesn't contain the relevant key, set the count to the number of fetched objects
				count = resultArray.count
			}
			
			return (Mapper<T>().mapArray(resultArray)!, count)
		}
	}
	
	func accessTokenForChannel(channelName: String) -> SignalProducer<AccessToken, NSError> {
		return request(.AccessToken(channelName: channelName)).map {
			resultObject in
			return Mapper<AccessToken>().map(resultObject)!
		}
	}
	
	func m3u8URLForChannel(channelName: String, accessToken : AccessToken) -> SignalProducer<String, NSError> {
		return SignalProducer {
			observer, disposable in
			let urlString = "http://usher.justin.tv/api/channel/hls/\(channelName)?allow_source=true&token=\(accessToken.token)&sig=\(accessToken.sig)"
			observer.sendNext(urlString)
		}
	}
	
	func m3u8URLForChannel(channelName: String) -> SignalProducer<String, NSError> {
		return accessTokenForChannel(channelName).flatMap(.Latest) {
			(accessToken) -> SignalProducer<String, NSError> in
			return self.m3u8URLForChannel(channelName, accessToken: accessToken)
		}
	}
	
	func getTopGames(page: Int) -> SignalProducer<(objects: [TopGame], count: Int), NSError> {
		return request(TwitchRouter.GamesTop(page: page)).map({ (result: (objects: [TopGame], totalCount: Int)) in
			return (result.objects, result.totalCount)
		})
	}
	
	func searchGames(query: String) -> SignalProducer<(objects: [Game], count: Int), NSError> {
		return request(TwitchRouter.SearchGames(query: query), resultPath: "games").flatMap(.Latest) { (result: (items: [Game], count: Int)) in
			return SignalProducer {
				observer, disposable in
				observer.sendNext((result.items, result.count))
			}
		}
	}
	
	func streamForGame(gameName: String, page: Int) -> SignalProducer<(objects: [Stream], count: Int), NSError> {
		return request(TwitchRouter.Streams(gameName: gameName, page: page), resultPath: "streams").flatMap(.Latest) { (result: (items: [Stream], count: Int)) in
			return SignalProducer {
				observer, disposable in
				observer.sendNext((result.items, result.count))
			}
		}
	}
}
