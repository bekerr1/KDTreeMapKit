//
//  KDTreeData.swift
//  KDTreeMapKit
//
//  Created by brendan kerr on 6/7/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import Foundation


enum TreeDataIdentifier {
    
    case Left
    case Right
    case Root
    case Nothing
}




struct TreeData {
    
    let controlValue: Double
    let controlAxis: Axis
    let nodeSide: TreeDataIdentifier
    let prevNodeSide: TreeDataIdentifier
    var backThroughCheck: Bool
    
    init(cv: Double, ca: Axis, ns: TreeDataIdentifier, pns: TreeDataIdentifier, btc: Bool) {
        controlValue = cv
        controlAxis = ca
        nodeSide = ns
        prevNodeSide = pns
        backThroughCheck = btc
        
    }
}



enum Axis {
    
    case X
    case Y
    case Point
}


