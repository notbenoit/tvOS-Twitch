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

enum TwitchRouter {
	static let baseURLString = Constants.API_URL
	static let tokenURLString = Constants.API_URL_TOKEN
	static let perPage: Int = 20
	
	case gamesTop(page: Int)
	case searchGames(query: String)
	case streams(gameName: String?, page: Int)
	case searchStream(query: String, page: Int)
	case accessToken(channelName: String)
	
	var pathAndParams: (path: String, parameters: [String:Any]) {
		switch self {
		case .gamesTop(let page):
			return ("/games/top", ["limit":TwitchRouter.perPage, "offset":page*TwitchRouter.perPage])
		case .searchGames(let query):
			return ("/search/games", ["live":true, "type":"suggest", "query":query])
		case .streams(let gameName, let page):
			var params: [String:Any] = [:]
			if let gameName = gameName {
				params["game"] = gameName
			}
			params["limit"] = TwitchRouter.perPage
			params["offset"] = page*TwitchRouter.perPage
			return ("/streams", params)
		case .searchStream(let query, let page):
			var params: [String:Any] = [:]
			params["query"] = query
			params["limit"] = TwitchRouter.perPage
			params["offset"] = page*TwitchRouter.perPage
			return ("/search/streams", params)
		case .accessToken(let channelName):
			return ("/channels/\(channelName)/access_token", [:])
		}
	}
	
	func asURLRequest() throws -> URLRequest {
		let stringAPIURL: String = {
			switch self {
			case .gamesTop(_), .searchGames(_), .streams(_, _), .searchStream(_, _):
				return TwitchRouter.baseURLString
			case .accessToken(_):
				return TwitchRouter.tokenURLString
			}
		}()
		let URL = Foundation.URL(string: stringAPIURL)!
		let URLRequest = Foundation.URLRequest(url: URL.appendingPathComponent(pathAndParams.path))
		let encoding = URLEncoding()
		return try encoding.encode(URLRequest, with: pathAndParams.parameters)
	}
	
	var URLString: String {
		let urlDetails = pathAndParams
		switch self {
		case .accessToken(_):
			return TwitchRouter.tokenURLString + urlDetails.path
		default:
			return TwitchRouter.baseURLString + urlDetails.path
		}
		
	}
	
	var method: Alamofire.HTTPMethod {
		switch self {
		default:
			return .get
		}
	}
}

extension TwitchRouter: URLRequestConvertible { }
