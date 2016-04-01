//
//  ReactiveController.swift
//  Contender
//
//  Created by Benoît Layer on 20/02/2016.
//  Copyright © 2016 Fueled. All rights reserved.
//

import Foundation
import ReactiveCocoa
import DataSource
import Result

class ReactiveController: UIViewController, Disposing {
	private let appearPipedSignal = Signal<Void, NoError>.pipe()
	var appear: Signal<Void, NoError> { return appearPipedSignal.0 }
	private let disappearPipedSignal = Signal<Void, NoError>.pipe()
	var disappear: Signal<Void, NoError> { return disappearPipedSignal.0 }
	let disposable = CompositeDisposable()
	private let keyboardVisibleProperty = MutableProperty(false)
	var keyboardVisible: SignalProducer<Bool, NoError> { return keyboardVisibleProperty.producer }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		appearPipedSignal.1.sendNext(())
		
		#if os(iOS)
			let keyboardWillShowProducer = NSNotificationCenter.defaultCenter()
				.rac_notifications(UIKeyboardWillShowNotification, object: nil)
				.takeUntil(disappear)
			let keyboardWillHideProducer = NSNotificationCenter.defaultCenter()
				.rac_notifications(UIKeyboardWillHideNotification, object: nil)
				.takeUntil(disappear)
			
			keyboardWillShowProducer.start(self, ReactiveController.keyboardWillShow)
			keyboardWillHideProducer.start(self, ReactiveController.keyboardWillHide)
			
			let keyboardWillShowBoolProducer = keyboardWillShowProducer.map { _ in return true }
			let keyboardWillHideBoolProducer = keyboardWillHideProducer.map { _ in return false }
			let keyboardVisibleProducer = SignalProducer<SignalProducer<Bool, NoError>, NoError>(values:
				[keyboardWillShowBoolProducer, keyboardWillHideBoolProducer])
				.flatten(.Merge)
				.skipRepeats()
			disposable +=	keyboardVisibleProperty <~ keyboardVisibleProducer.takeUntil(disappear)
		#endif
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		disappearPipedSignal.1.sendNext(())
	}
	
	deinit {
		appearPipedSignal.1.sendCompleted()
		disappearPipedSignal.1.sendCompleted()
		disposable.dispose()
	}
}

// MARK: - Keyboard management
extension ReactiveController {
	func keyboardWillShow(notification: NSNotification) {
		// Override in subclasses
	}
	
	func keyboardWillHide(notification: NSNotification) {
		// Override in subclasses
	}
}