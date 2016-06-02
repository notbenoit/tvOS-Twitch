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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		// Add a search view controller to the root `UITabBarController`.
		if let tabController = window?.rootViewController as? UITabBarController {
			tabController.viewControllers?.append(packagedSearchController())
		}

		return true
	}

	func application(app: UIApplication, openURL url: NSURL, options: [String: AnyObject]) -> Bool {
		if
			let tabBarController = window?.rootViewController as? UITabBarController,
			let homeViewController = tabBarController.viewControllers?.first as? TwitchHomeViewController,
			gameName = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)?
				.queryItems?
				.filter({ $0.name == "name" })
				.first?.value {
					homeViewController.selectGame(gameName)
		}

		return true
	}

	// MARK: Convenience

	/*
	A method demonstrating how to encapsulate a `UISearchController` for presentation in, for example, a `UITabBarController`
	*/
	func packagedSearchController() -> UIViewController {
		// Load a `SearchResultsViewController` from its storyboard.
		let storyboard = UIStoryboard(name: "Search", bundle: nil)
		guard let searchResultsController = storyboard.instantiateInitialViewController() as? SearchResultsViewController else {
			fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
		}

		/*
		Create a UISearchController, passing the `searchResultsController` to
		use to display search results.
		*/
		let searchController = UISearchController(searchResultsController: searchResultsController)
		searchController.view.backgroundColor = UIColor.whiteColor()
		searchController.searchResultsUpdater = searchResultsController
		searchController.searchBar.placeholder = NSLocalizedString("Starcraft, ESL, Overwatch...", comment: "")

		// Contain the `UISearchController` in a `UISearchContainerViewController`.
		let searchContainer = UISearchContainerViewController(searchController: searchController)
		searchContainer.title = NSLocalizedString("Search", comment: "")

		// Finally contain the `UISearchContainerViewController` in a `UINavigationController`.
		let searchNavigationController = UINavigationController(rootViewController: searchContainer)
		return searchNavigationController
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}
