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
import Alamofire

enum TwitchRouter: URLRequestConvertible {
	static let baseURLString = Constants.API_URL
	static let tokenURLString = Constants.API_URL_TOKEN
	static let perPage: Int = 20
	
	case GamesTop(page: Int)
	case SearchGames(query: String)
	case Streams(gameName: String, page: Int)
	case AccessToken(channelName: String)
	
	var URLRequest: NSMutableURLRequest {
		let result: (path: String, parameters: [String:AnyObject]) = {
			switch self {
			case .GamesTop(let page):
				return ("/games/top", ["limit":TwitchRouter.perPage, "offset":page*TwitchRouter.perPage])
			case .SearchGames(let query):
				return ("/search/games", ["live":true, "type":"suggest", "query":query])
			case .Streams(let gameName, let page):
				return ("/streams", ["game":gameName, "limit":TwitchRouter.perPage, "offset":page*TwitchRouter.perPage])
			case .AccessToken(let channelName):
				return ("/channels/\(channelName)/access_token", [:])
			}
		}()
		let stringAPIURL: String = {
			switch self {
			case .GamesTop(_), .SearchGames(_), .Streams(_, _):
				return TwitchRouter.baseURLString
			case .AccessToken(_):
				return TwitchRouter.tokenURLString
			}
		}()
		let URL = NSURL(string: stringAPIURL)!
		let URLRequest = NSURLRequest(URL: URL.URLByAppendingPathComponent(result.path))
		let encoding = Alamofire.ParameterEncoding.URL
		
		return encoding.encode(URLRequest, parameters: result.parameters).0
	}
}