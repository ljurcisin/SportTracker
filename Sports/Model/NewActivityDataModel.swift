//
//  NewActivityModel.swift
//  Sports
//
//  Created by Lubomir Jurcisin on 04/04/2020.
//  Copyright © 2020 Lubomir Jurcisin. All rights reserved.
//

import Foundation
import CoreLocation

/**
 NewActivityData structure hods data needed for creating new activity record
 it has computed property which says if all needed data are set
*/
struct NewActivityData {
    var duration: Int = 0
    var intensity:Float = 2.5
    var sport = SportType.run
}
