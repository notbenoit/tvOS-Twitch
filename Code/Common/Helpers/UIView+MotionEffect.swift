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

extension UIView {
	func applyMotionEffectForX(x: Float, y: Float) {
		let x = abs(x)
		let y = abs(y)
		let effectX = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
		effectX.minimumRelativeValue = NSNumber(float: -x)
		effectX.maximumRelativeValue = NSNumber(float: x)
		let effectY = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
		effectY.minimumRelativeValue = NSNumber(float: -y)
		effectY.maximumRelativeValue = NSNumber(float: y)
		let effectGroup = UIMotionEffectGroup()
		effectGroup.motionEffects = [effectX, effectY]
		self.addMotionEffect(effectGroup)
	}
	
	func removeMotionEffects() {
		guard let effect = self.motionEffects.first else {
			return
		}
		self.removeMotionEffect(effect)
	}
}
