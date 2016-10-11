//
//  AdService.swift
//  TwitchTV
//
//  Created by Benoît Layer on 09/10/2016.
//  Copyright © 2016 Benoit Layer. All rights reserved.
//

import Foundation
import COLORAdFramework

final class AdService {
	static let shared: AdService = AdService()
	
	fileprivate var placements: [String] = [
		COLORAdFrameworkPlacementBetweenLevels,
		COLORAdFrameworkPlacementPause,
		COLORAdFrameworkPlacementStageComplete
	]
	
	var nextPlacement: String {
		let ret = placements.first!
		placements = Array(placements.dropFirst())
		placements.append(ret)
		return ret
	}
}
