//
//  ColorTVExtension.swift
//  TwitchTV
//
//  Created by Benoît Layer on 29/05/2016.
//  Copyright © 2016 Benoit Layer. All rights reserved.
//

import UIKit
import ReactiveCocoa
import COLORAdFramework
import Result

func adProducerBeforeController<T: UIViewController>(viewController: T, inController: UIViewController, placement: String) -> SignalProducer<T, NSError> {
	return SignalProducer {
		(observer, disposable) in
		COLORAdController.sharedAdController().adViewControllerForPlacement(placement, withCompletion: { (controller, error) in
			guard let controller = controller else {
				observer.sendNext(viewController)
				observer.sendCompleted()
				return
			}
			controller.adCompleted = {
				controller.dismissViewControllerAnimated(false) {
					observer.sendNext(viewController)
					observer.sendCompleted()
				}
			}
			dispatch_async(dispatch_get_main_queue()) {
				inController.presentViewController(controller, animated: true, completion: nil)
			}
		})
	}
}
