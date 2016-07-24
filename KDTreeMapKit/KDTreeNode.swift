//
//  KDTreeNode.swift
//  KDTreeMapKit
//
//  Created by brendan kerr on 6/7/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import Foundation


struct Pair   {
    
    var x: Double
    var y: Double
    
    init(xc: Double, yc: Double) {
        x = xc
        y = yc
    }
    
    
}


struct QueryArea  {
    
    var origin: Pair
    var width: Double
    var height: Double
    
    init(xc: Double, yc: Double, w: Double, h: Double) {
        origin = Pair(xc: xc, yc: yc)
        width = w
        height = h
    }
    
}

protocol Coordinate {
    func x()
    func y()
}





class Node<PointSystem>  {
    
    
    //MARK: Properties
    
    var leftNode: Node?
    var rightNode: Node?
    
    //Temporary until Long/Lat points are used
    var dataPoint: PointSystem?
    
    //Variable that influences which way the kd tree branches/spans out
    var control: Double?
    
    //variable to show if node is an axis or a point
    var controlAxis = Axis.Point
    
    init(dp: PointSystem) {
        dataPoint = dp
    }
    
    init() {
        
    }
    
    /*
     Want to take the middle point and "draw a line" through it
     Seperating the 'lower' and 'upper' points of the axis (even
     numbers are x and odd numbers are y).
     */
    func buildKDTree(var points: [PointSystem], axis: Int) -> Node? {
        
        if points.count == 1 {
            let current = Node(dp: points[0])
            return current
        }
        
        
        var p1 = [Pair]()
        var p2 = [Pair]()
        
        var median: Double = 0.0
        let current = Node()
        
        //x axis split
        if axis % 2 == 0 {
            
            //sort the points by x axis
            points.sortInPlace { (element1, element2) -> Bool in
                return element1.x < element2.x
            }
            //No points in this array, return the node
            if (points.count == 0) {
                return current
            }
            //set the control (variable used to direct a query) to the median of the x points
            median = medianOfX(points)
            current.control = median
            
            //seperate the points by the median
            for pt in points {
                
                if pt.x < median {
                    p1.append(pt)
                } else {
                    p2.append(pt)
                }
            }
            
            current.controlAxis = .X
          //y axis split
        } else {
            //sort y
            points.sortInPlace { (element1, element2) -> Bool in
                return element1.y < element2.y
            }
            //return on empty array
            if (points.count == 0) {
                return current
            }
            //median of y's
            median = medianOfY(points)
            current.control = median
            
            //seperate by y
            for pt in points {
                
                if pt.y < median {
                    p1.append(pt)
                } else {
                    p2.append(pt)
                }
            }
            
            current.controlAxis = .Y
            
        }
        //recurse down the tree building the left node tree with < median and right node tree with > median
        current.leftNode = buildKDTree(p1, axis: axis+1)
        current.rightNode = buildKDTree(p2, axis: axis+1)
        
        return current
        
    }
    
    
    
    func medianOfX(points: [Pair]) -> Double {
        
        let firstPair = points.first
        let lastPair = points.last
        
        return (((lastPair?.x)! - (firstPair?.x)!) / 2) + (firstPair?.x)!
        
    }
    
    
    func medianOfY(points: [Pair]) -> Double {
        
        let firstPair = points.first
        let lastPair = points.last

        return (((lastPair?.y)! - (firstPair?.y)!) / 2) + (firstPair?.y)!

        
    }
    
}
