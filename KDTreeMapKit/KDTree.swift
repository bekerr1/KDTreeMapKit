 //
//  KDTree.swift
//  KDTreeMapKit
//
//  Created by brendan kerr on 3/7/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import simd


class KDTree  {
    
    //MARK: Properties
    
    var rootNode: Node
    var currentPointsToPlot = [Pair]() //MKMapPoint
    
    var testData = [TreeData]()
    var testDataIndex = -1
    //var currentViewIndex = 0
    
    init() {
       rootNode = Node()
    }
    
    func buildTree(inout pts: [Pair], axis: Int = 0) { //MKMapPoint
        
        rootNode = rootNode.buildKDTree(&pts, axis: axis)!
    }
    
    
    //Want to print leaf nodes and their parent (first level control nodes)
    //If node . left = null and node . right = null, isa leaf node
    //If node . left . control = null and node . right . control = null, isa
    //first level control node
    func inOrderTraversal(n: Node?) {
        
        if (n == nil) {
            return
        }
        inOrderTraversal(n?.leftNode)
        
        if (n!.leftNode == nil && n!.rightNode == nil) {
            print("Node is a leaf with X \(n?.dataPoint?.x) and Y \(n?.dataPoint?.y)")
        }
        
        if ((n?.leftNode?.control == nil || n?.rightNode?.control == nil) && n?.control != nil) {
            print("Control for the child nodes is \(n?.control) and Influences the \(n?.controlAxis) axis")
        }
        
        inOrderTraversal(n?.rightNode)
        
        
    }
    
    //Goal is to get to the leaf where the query point "belongs".  Once at this point,
    //Can get points around and see which points lie inside the bounds.
    func querySectionWith(center: Pair, Query queryArea: QueryArea, Root rootNode: Node) -> Node {
        
        
        
        let controlValue = rootNode.control
        var dataIndex: TreeDataIdentifier = .Nothing
        
        if testDataIndex >= 0 {
           dataIndex = testData[testDataIndex].nodeSide
        }  else {
            dataIndex = .Root
        }
        
        
        if rootNode.controlAxis == .X {
            

            
            //Check if the center of the query area is less than the control
            //if it is, recurse down the left side, else recurse down the right side
            //let cx: Double = center.x.convert()
            if let leftNode = rootNode.leftNode where center.x < controlValue {
                
                //Data Collection (can be eliminated)
                let data = TreeData(cv: controlValue!, ca: Axis.X, ns: TreeDataIdentifier.Left, pns: dataIndex, btc: false)
                testData.append(data)
                testDataIndex += 1
                
                querySectionWith(center, Query: queryArea, Root: leftNode)
                
                //When function comes back around, check if the query area spans the other side
                //of the control, and if it does, possible points inside the area are possible,
                //recurse down that side and check.
                if let rightNode = rootNode.rightNode where center.x + queryArea.width / 2 > controlValue {
                    testData[testDataIndex].backThroughCheck = true
                    querySectionWith(center, Query: queryArea, Root: rightNode)
                    
                }
            } else {
                
                
                if let rightNode = rootNode.rightNode {
                    
                    //Data Collection (can be eliminated)
                    let data = TreeData(cv: controlValue!, ca: Axis.X, ns: TreeDataIdentifier.Right, pns: dataIndex, btc: false)
                    testData.append(data)
                    testDataIndex += 1
                    
                    querySectionWith(center, Query: queryArea, Root: rightNode)
                    
                    //When function comes back around, check if the query area spans the other side
                    //of the control, and if it does, possible points inside the area are possible,
                    //recurse down that side and check.
                    if let leftNode = rootNode.leftNode where center.x - queryArea.width / 2 < controlValue {
                        testData[testDataIndex].backThroughCheck = true
                        querySectionWith(center, Query: queryArea, Root: leftNode)
                    }
                    
                    
                }
                
            }
            
        } else if rootNode.controlAxis == .Y {
        

            
            //Check if the center of the query area is less than the control
            //if it is, recurse down the left side, else recurse down the right side
            //let cy: Double = center.y.convert()
            if let leftNode = rootNode.leftNode where center.y < controlValue {
                
                let data = TreeData(cv: controlValue!, ca: Axis.Y, ns: TreeDataIdentifier.Left, pns: dataIndex, btc: false)
                testData.append(data)
                testDataIndex += 1
                
                querySectionWith(center, Query: queryArea, Root: leftNode)
                 
                //When function comes back around, check if the query area spans the other side
                //of the control, and if it does, possible points inside the area are possible,
                //recurse down that side and check.
                if let rightNode = rootNode.rightNode where center.y + queryArea.height / 2 > controlValue {
                    testData[testDataIndex].backThroughCheck = true
                    querySectionWith(center, Query: queryArea, Root: rightNode)
                    
                }
            } else {
                
                //Where condition failed and should recurse down the right side (center is greater)
                if let rightNode = rootNode.rightNode {
                    
                    let data = TreeData(cv: controlValue!, ca: Axis.Y, ns: TreeDataIdentifier.Right, pns: dataIndex, btc: false)
                    testData.append(data)
                    testDataIndex += 1
                    
                    querySectionWith(center, Query: queryArea, Root: rightNode)
                    
                    //When function comes back around, check if the query area spans the other side
                    //of the control, and if it does, possible points inside the area are possible,
                    //recurse down that side and check.
                    if let leftNode = rootNode.leftNode where center.y - queryArea.height / 2 < controlValue {
                        testData[testDataIndex].backThroughCheck = true
                        querySectionWith(center, Query: queryArea, Root: leftNode)
                    }
                    
                }
            }
            
        } else if rootNode.controlAxis == .Point {
            
            if let point = rootNode.dataPoint {
                
                let mapPoint = MKMapPointMake(point.x, point.y)
                let mapArea = MKMapRectMake(queryArea.origin.x, queryArea.origin.y, queryArea.width, queryArea.height)
                
                if MKMapRectContainsPoint(mapArea, mapPoint) {
                    
                    currentPointsToPlot.append(point)
            
                }
                
            }
            else {
                print("Data Point doesnt Exist.")
            }
            
        }
        return rootNode
    }
    
    
    func resetTestData() {
        
        testData = [TreeData]()
        testDataIndex = -1
    }
    
    
 }












//protocol Sequence {
//    typealias GeneratorType : Generator
//    func generate() -> GeneratorType
//}
//

//struct TreePoint<T where T: Comparable, T: Equatable, T: NumericType, T: NumberConvertible>  {
//
//    var x: T
//    var y: T
//
//    init(xc: T, yc: T) {
//        x = xc
//        y = yc
//    }
//
//}




/* Function to check if a point is inside an area.
Because we are given the middle point and width/height, one can:
(Only use these when you need to query CGRect)
if middle.x - width/2 < point.x and middle.y - height/2 < point.y -- 1
if middle.x - width/2 < point.x and middle.y + height/2 > point.y -- 2
if middle.x + width/2 > point.x and middle.y - height/2 < point.y -- 3
if middle.x + width/2 > point.x and middle.y + height/2 > point.y -- 4

*/
//    func pointInsideQuery1(point: MKMapPoint, Query queryArea: CGRect) -> Bool {
//
//        return queryArea.center.x - queryArea.width/2 < point.x && queryArea.y - queryArea.height/2 < point.y
//    }
//    func pointInsideQuery2(point: MKMapPoint, Query queryArea: CGRect) -> Bool {
//
//        return queryArea.center.x - queryArea.width/2 < point.x && queryArea.y + queryArea.height/2 > point.y
//    }
//    func pointInsideQuery3(point: MKMapPoint, Query queryArea: CGRect) -> Bool {
//
//        return queryArea.center.x + queryArea.width/2 > point.x && queryArea.y - queryArea.height/2 < point.y
//    }
//    func pointInsideQuery4(point: MKMapPoint, Query queryArea: CGRect) -> Bool {
//
//        return queryArea.center.x + queryArea.width/2 > point.x && queryArea.y + queryArea.height/2 > point.y
//    }
//
 
 
 
 
 //class Node {
 //
 //
 //    //MARK: Properties
 //
 //    var leftNode: Node?
 //    var rightNode: Node?
 //
 //    //Temporary until Long/Lat points are used
 //    var dataPoint: MKMapPoint?
 //    var control: Double?
 //    var controlAxis = Axis.Point
 //
 //    init(dp: MKMapPoint) {
 //        dataPoint = dp
 //    }
 //
 //    init() {
 //
 //    }
 //
 //
 //
 //
 //    /*
 //    Want to take the middle point and "draw a line" through it
 //    Seperating the 'lower' and 'upper' points of the axis (even
 //    numbers are x and odd numbers are y).
 //    */
 //    func buildKDTree(var points: [MKMapPoint], axis: Int) -> Node? {
 //
 //        if points.count == 1 {
 //            let current = Node(dp: points[0])
 //            return current
 //        }
 //
 //
 //        var p1 = [MKMapPoint]()
 //        var p2 = [MKMapPoint]()
 //
 //        var median: Double = 0.0
 //        let current = Node()
 //
 //
 //
 ////        output = points.reduce(MKMapPoint(x: 0.0, y: 0.0)) {
 ////            return MKMapPoint(x: $0.x + $1.x, y: $0.y + $1.y)
 ////        }
 //
 //        if axis % 2 == 0 {
 //
 //            points.sortInPlace { (element1, element2) -> Bool in
 //                return element1.x < element2.x
 //            }
 //
 //            if (points.count == 0) {
 //                //print("Nothing")
 //                return current
 //            }
 //
 //            median = ((Double((points.last?.x)!) - Double((points.first?.x)!)) / 2.0) + Double((points.first?.x)!)
 //            current.control = median
 //
 //
 //            for pt in points {
 //                if pt.x < median {
 //                    p1.append(pt)
 //                } else {
 //                    p2.append(pt)
 //                }
 //            }
 //
 //            current.controlAxis = .X
 //
 //        } else {
 //
 //            points.sortInPlace { (element1, element2) -> Bool in
 //                return element1.y < element2.y
 //            }
 //
 //            if (points.count == 0) {
 //                //print("Nothing")
 //                return current
 //            }
 //
 //            median = ((Double((points.last?.y)!) - Double((points.first?.y)!)) / 2.0) + Double((points.first?.y)!)
 //            current.control = median
 //
 //            for pt in points {
 //                if pt.y < median {
 //                    p1.append(pt)
 //                } else {
 //                    p2.append(pt)
 //                }
 //            }
 //
 //            current.controlAxis = .Y
 //
 //        }
 //
 //        current.leftNode = buildKDTree(p1, axis: axis+1)
 //        current.rightNode = buildKDTree(p2, axis: axis+1)
 //        
 //        return current
 //       
 //    }
 //    
 //    
 //    
 //}
 //
 


