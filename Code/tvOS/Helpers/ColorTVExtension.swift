//
//  ColorTVExtension.swift
//  TwitchTV
//
//  Created by Benoît Layer on 29/05/2016.
//  Copyright © 2016 Benoit Layer. All rights reserved.
//

import UIKit
import ReactiveSwift
import COLORAdFramework
import Result

func adProducerBeforeController<T: UIViewController>(_ viewController: T, inController: UIViewController, placement: String) -> SignalProducer<T, NSError> {
	return SignalProducer {
		(observer, disposable) in
		COLORAdController.sharedAdController().adViewController(forPlacement: placement, withCompletion: { controller, error in
			guard let controller = controller else {
				observer.send(value: viewController)
				observer.sendCompleted()
				return
			}
			controller.addCompletionHandler { watched in
				controller.dismiss(animated: false) {
					observer.send(value: viewController)
					observer.sendCompleted()
				}
			}
			DispatchQueue.main.async {
				inController.present(controller, animated: true, completion: nil)
			}
			}, expirationHandler: { expiredController in
				
		})
	}
}
