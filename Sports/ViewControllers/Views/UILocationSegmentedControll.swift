//
//  UILocationSegmentedControll.swift
//  Sports
//
//  Created by Lubomir Jurcisin on 27/04/2021.
//  Copyright © 2021 Lubomir Jurcisin. All rights reserved.
//

import UIKit

/**
 UILocationSegmentedControll is customized  uisegmentcontrol
 Needed for getting informed even when value isnt changed by clicking on the same value
 Also giving user ability to prevent index change
*/
class UILocationSegmentedControll: UISegmentedControl {
    
    var delegate : UILocationSegmentedControllDelegate?
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let oldVal = selectedSegmentIndex
        super.touchesEnded(touches, with: event)
        if !(delegate?.isSegmentEnabled(selectedSegmentIndex) ?? false) {
            selectedSegmentIndex = oldVal
        }
        
        if oldVal == selectedSegmentIndex {
            delegate?.segmentNotChanged()
        } else {
            delegate?.segmentChanged()
        }
    }
}

protocol UILocationSegmentedControllDelegate {
    func segmentChanged()
    func segmentNotChanged()
    func isSegmentEnabled(_ index: Int) -> Bool
}
