//
//  KDDemoViewController.swift
//  KDTreeMapKit
//
//  Created by brendan kerr on 3/12/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit
import MapKit

class KDDemoViewController: UIViewController, UIGestureRecognizerDelegate {

    
    //MARK: properties
    var screenViewsFromMapPoints = [UIView]()
    var screenPoints = [CGPoint]()
    
    @IBOutlet weak var nodeColorKey: UIView!
    @IBOutlet weak var queryOptions: UISegmentedControl!
    var queryArea: UIView!
    
    var pointMode: Bool = true
    
    var maxX: Double = 0.0
    var maxY: Double = 0.0
    
    var pvArray = Array<Array<TreeData>>()
    var queryArr = Array<MKMapRect>()
    var cgQueryViewArr = Array<(CGPoint, CGRect)>()
    var viewLines = Array<UIView>()
    var unique = Array<MKMapPoint>()
    var uniquePairs = Array<Pair>()
    
    let doubletree = KDTree()
    
    var currentIteration = 0
    
    var va = 1.0
    var vaM = 0.0
    
    //MARK: init
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        
        
        queryArea = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        queryArea.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)
        queryArea.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(queryArea)
        queryArea.hidden = true
        
        
        let parser = PointParser()
        parser.parseData()
        
        unique = parser.CLLocationPoints.unique
        plotMapPointsInUIView(unique, plotView: self.view)
        uniquePairs = pairsFromCGPoints(screenPoints)
        
        let start = CFAbsoluteTimeGetCurrent()
        doubletree.buildTree(uniquePairs)
        let end = CFAbsoluteTimeGetCurrent()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateGesture(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(_:)))
        queryArea.gestureRecognizers = [panGesture, rotateGesture, pinchGesture]
        
        print(end - start)
        
        
        
        //print(end - start)
        //tree.inOrderTraversal(tree.rootNode)
        //let queryArea = determineQueryArea(self.queryArea)
        
        //
        //collectQueryAreaDataFor(queryArr)
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
       // self.view.backgroundColor = UIColor.greenColor()
        //startPointCycle()
    }
    
    
    
    
    
    //For all points, this function is used to show the graphics the tree
    //does to search for every point
    func collectQueryPointDataFor(Points points: [Pair],
        QueryArea query: QueryArea, Tree tree: KDTree) {
        
        var i = 0
        
        for view in screenViewsFromMapPoints {
            view.backgroundColor = UIColor.blackColor()
            tree.querySectionWith(points[i], Query: query, Root: tree.rootNode)
            pvArray.append(tree.testData)
            tree.resetTestData()
            i++
        }
    }
    
    
    //These functions are used to show what happens when the user queries different areas
    func collectMapQueryAreaDataFor(queryArea: MKMapRect) {
        
        let centerPair = Pair(xc: MKMapRectGetMidX(queryArea), yc: MKMapRectGetMidY(queryArea))
        let rectQuery = QueryArea(xc: queryArea.origin.x, yc: queryArea.origin.y, w: queryArea.size.width, h: queryArea.size.height)
        
        doubletree.querySectionWith(centerPair, Query: rectQuery, Root: doubletree.rootNode)
        
    }
    
//    func collectRectQueryAreaDataFor(queryArea: CGRect) {
//        
//        let centerPair = Pair<CGFloat>(xc: Double(CGRectGetMidX(queryArea)), yc: Double(CGRectGetMidY(queryArea)))
//        let rectQuery = QueryArea(xc: Double(queryArea.origin.x), yc: Double(queryArea.origin.y), w: Double(queryArea.size.width), h: Double(queryArea.size.height))
//        
//        tree.querySectionWith(centerPair, Query: rectQuery, Root: tree.rootNode)
//        
//    }

    func collectRectQueryAreaDataFor(queryArea: CGRect) {
        
        let centerPair = Pair(xc: Double(CGRectGetMidX(queryArea)), yc: Double(CGRectGetMidY(queryArea)))
        let rectQuery = QueryArea(xc: Double(queryArea.origin.x), yc: Double(queryArea.origin.y), w: Double(queryArea.size.width), h: Double(queryArea.size.height))
        
        doubletree.querySectionWith(centerPair, Query: rectQuery, Root: doubletree.rootNode)
        pvArray.append(doubletree.testData)
        
    }

    
    //MARK: Cycle
    
    func startCycle() {
        print(__FUNCTION__)
        
        
        
        if pointMode {
            
            var dispatch: Double = 0.5
            screenViewsFromMapPoints[currentIteration].backgroundColor = UIColor.redColor()
            self.view.bringSubviewToFront(screenViewsFromMapPoints[currentIteration])
            
            let pvs = pvArray[currentIteration]
            var lastControl = 0.0
            vaM = Double(1) / Double(pvs.count)
            newViewAlphaCycle()
            
            for pv in pvs {
                
                let dpt: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,
                    Int64(dispatch * Double(NSEC_PER_SEC)))
                
                dispatch_after(dpt, dispatch_get_main_queue(), { [unowned self] in
                    
                    lastControl = self.animateLineAtAxis(pv, Last: lastControl)
                    
                    })
                
                let viewAlpha = NSTimer(timeInterval: dispatch, target: self, selector: Selector.init("viewAlphaManip"), userInfo: nil, repeats: false)
                NSRunLoop.mainRunLoop().addTimer(viewAlpha, forMode: NSDefaultRunLoopMode)
                
                dispatch += 0.5
                
            }
            
            let timer = NSTimer(timeInterval: (dispatch + 0.5), target: self, selector: Selector.init("endPointCycle"), userInfo: nil, repeats: false)
            
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
            
        } else {
            
            var dispatch: Double = 4.0
            var lastControl = 0.0
            let pvs = pvArray[currentIteration]
            //Animate the screen rect to rect on file and add center point
            for rect in cgQueryViewArr {
                
//                let centerPoint = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 20.0, height: 20.0))
//                centerPoint.center = CGPointMake(CGRectGetMidX(rect.frame), CGRectGetMidY(rect.frame))
//                centerPoint.backgroundColor = UIColor.whiteColor()
                print("center \(rect.0) frame \(rect.1)")
                UIView.animateWithDuration(3.0, animations: {
                    self.queryArea.center = rect.0
                    self.queryArea.frame = rect.1
                    self.queryArea.layoutIfNeeded()

                    
                    }) { (complete: Bool) -> Void in
                        if complete {
                            //self.view.addSubview(centerPoint)
                            
                            
                        }
                
                        
                }
                
                self.queryArea.center = rect.0
                self.queryArea.frame = rect.1
                //for each screen rect on file, animate the point data affiliated
                //each point data should be for the center of the rect.
                for pv in pvs {
                    
                    print("center \(self.queryArea.center) frame \(self.queryArea.frame)")
                    let dpt: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,
                        Int64(dispatch * Double(NSEC_PER_SEC)))
                    
                    dispatch_after(dpt, dispatch_get_main_queue(), { [unowned self] in
                        
                        lastControl = self.animateLineAtAxis(pv, Last: lastControl)
                        
                        })
                    
                    let viewAlpha = NSTimer(timeInterval: dispatch, target: self, selector: Selector.init("viewAlphaManip"), userInfo: nil, repeats: false)
                    NSRunLoop.mainRunLoop().addTimer(viewAlpha, forMode: NSDefaultRunLoopMode)
                    
                    dispatch += 0.5

                    
                }
            }
            
            
        }
        
        
    }
    
    
    
    func endPointCycle() {
        print(__FUNCTION__)
        
        
        
        for line in viewLines {
            line.removeFromSuperview()
        }
        
        screenViewsFromMapPoints[currentIteration].backgroundColor = UIColor.blackColor()
        currentIteration++
        
        if currentIteration < 20 {
            startCycle()
        } else {
            print("All Points Iterated")
        }
        
    }
    
    
    func newViewAlphaCycle () {
        va = 1.0
    }
    
    
    func viewAlphaManip() {
        
        va -= vaM
    }
    
    
    //MARK: line animation
    
    
    func animateLineAtAxis(data: TreeData, Last lastControl: Double) -> Double {
        
        print("Dispatch after called")
        
        var viewLine: UIView?
        var viewLine2: UIView?
        var lastCtrl = 0.0
        
        //x axis
        if data.controlAxis == Axis.X {
            lastCtrl = data.controlValue
            
            
            if data.prevNodeSide == TreeDataIdentifier.Left  { //left side
                
                viewLine = UIView(frame: CGRect(x:lastCtrl , y: 0.0, width: 3.0, height: lastControl))
                
            } else if data.prevNodeSide == TreeDataIdentifier.Right { //Right Side
                
                viewLine = UIView(frame: CGRect(x:lastCtrl , y: lastControl, width: 3.0, height: Double(view.frame.size.height)))
            } else {
                
                viewLine = UIView(frame: CGRect(x:lastCtrl , y: 0.0, width: 3.0, height: Double(view.frame.size.height)))
            }
            
            
        } else {
            
            lastCtrl = data.controlValue
            
            if data.prevNodeSide == TreeDataIdentifier.Left  { //left side
                
                viewLine = UIView(frame: CGRect(x: 0, y: lastCtrl, width: lastControl, height: 3.0))
                
            } else if data.prevNodeSide == TreeDataIdentifier.Right { //Right Side
                
                viewLine = UIView(frame: CGRect(x: lastControl, y: lastCtrl, width: Double(view.frame.size.width), height: 3.0))
            } else {
                
                viewLine = UIView(frame: CGRect(x: 0.0, y: lastCtrl, width: Double(view.frame.size.width), height: 3.0))
            }
            
            
        }
        
        print("Plotted line at x point: \(viewLine!.frame.origin.x) and y point: \(viewLine!.frame.origin.y)")
        
        viewLine2 = UIView(frame: viewLine!.frame)
        viewLine2?.backgroundColor = UIColor(red: 0.0, green: 255.0, blue: 255.0, alpha: 1.0)
        viewLine!.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 255.0, alpha: 1.0)
        viewLines.append(viewLine!)
        viewLines.append(viewLine2!)
        self.view.addSubview(viewLine2!)
        self.view.addSubview(viewLine!)
        viewLine2!.alpha = 1.0
        viewLine!.alpha = CGFloat(va)
        //viewLine!.alpha = 0.0
        
        return lastCtrl
    }
    

    
    //MARK: Points plot functions
    
    func plotMapPointsInUIView(points: [MKMapPoint], plotView: UIView) {
        
        
        var minX = 1000000000.0000
        var minY = 1000000000.0000
        for point in points {
            if maxX < point.x {
                maxX = point.x
            }
            if maxY < point.y {
                maxY = point.y
            }
            if minX > point.x {
                minX = point.x
            }
            if minY > point.y {
                minY = point.y
            }
        }
        
        for point in points {
            let screenPoint = CGPoint(x: XscreenPointFromMapPoint(point.x, maxX: maxX), y: YscreenPointFromMapPoint(point.y, maxY: maxY))
            
            screenPoints.append(screenPoint)
            let pointView = UIView(frame: CGRect(x: 0, y: 0, width: 20.0, height: 20.0))
            pointView.center = CGPoint(x: screenPoint.x, y: screenPoint.y)
            pointView.backgroundColor = UIColor.blueColor()
            pointView.layer.cornerRadius = 20.0
            
            
            plotView.addSubview(pointView)
            screenViewsFromMapPoints.append(pointView)
            
        }
        
        
        
        
        
    }
    
    
    //MARK: Utility for this current range
    
    func XscreenPointFromMapPoint(xPoint: Double, maxX: Double) -> Double {
        
        return (((xPoint) / maxX) * Double(self.view.frame.size.width) - 374.1) * 300
    }
    
    func YscreenPointFromMapPoint(yPoint: Double, maxY: Double) -> Double {
        
        return (((yPoint) / maxY) * Double(self.view.frame.size.height) - 660) * 50
    }

    
    func XmapPointFromScreenPoint(xPoint: CGFloat, maxX: CGFloat, maxMapX: Double) -> Double {
        
        return (((Double(xPoint) / 300) + 374.1) / Double(self.view.frame.size.width)) * maxMapX
    }
    
    func YmapPointFromScreenPoint(yPoint: CGFloat, maxY: CGFloat, maxMapY: Double) -> Double {
        
        return (((Double(yPoint) / 50) + 660) / Double(self.view.frame.size.height)) * maxMapY
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pairsFromMapPoints(mappoints: [MKMapPoint]) -> [Pair] {
        
        var pairArr: [Pair] = [Pair]()
        for point in mappoints {
            let newPair = Pair(xc: point.x, yc: point.y)
            pairArr.append(newPair)
        }
        
        return pairArr
    }
    
    
    func pairsFromCGPoints(cgPoints: [CGPoint]) -> [Pair] {
        
        var pairArr: [Pair] = [Pair]()
        for point in cgPoints {
            let newPair = Pair(xc: Double(point.x), yc: Double(point.y))
            pairArr.append(newPair)
        }
        
        return pairArr
    }
    
    
    
    
    
    //MARK: Gestures
    
    
    func panGesture(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPointMake(recognizer.view!.center.x + translation.x, recognizer.view!.center.y + translation.y)
        print("recognizer: \(recognizer.view!.center) queryView: \(queryArea.center)")
        recognizer.setTranslation(CGPoint(x: 0.0, y: 0.0), inView: self.view)
    }
    
    
    func rotateGesture(recognizer: UIRotationGestureRecognizer) {
        
        recognizer.view?.transform = CGAffineTransformRotate((recognizer.view?.transform)!, recognizer.rotation)
        recognizer.rotation = 0
    }
    
    
    func pinchGesture(recognizer: UIPinchGestureRecognizer) {
        
        recognizer.view?.transform = CGAffineTransformScale((recognizer.view?.transform)!, recognizer.scale, recognizer.scale)
        recognizer.scale =  1
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    
    //MARK: Actions
    
    @IBAction func recordViewData(sender: UIButton) {
        
        //let queryAreaAt = determineQueryArea(self.queryArea)'
        if pointMode {
            
            collectQueryPointDataFor(Points: uniquePairs, QueryArea: QueryArea(xc: 0.0, yc: 0.0, w: 0.0, h: 0.0), Tree: doubletree)
            
        } else {
            collectRectQueryAreaDataFor(self.queryArea.frame)
            
            cgQueryViewArr.append((self.queryArea.center, self.queryArea.frame))
        }
        

    }
    
    
    @IBAction func animateData(sender: UIButton) {
        
        startCycle()
        
    }

    @IBAction func queryOptionAction(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
            
        case 0:
            queryArea.hidden = true
            pointMode = true
            
        case 1:
            queryArea.hidden = false
            pointMode = false
            
        default:
            print("dont matter")
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


//extension Double : GeneratorType, SequenceType {
//    
//    public typealias Generator = Double
//    mutating func next() -> Generator {
//        return self
//        
//    }
//    
//    let n = self
//    
//    public typealias Element = Double
//    public func generate() -> Element? {
//        if n {
//           return self
//        }
//        
//    }
//
//}


//    func generate() -> GeneratorType {
//
//    }
//}
//
//protocol Sequence {
//    typealias CGFloatGenerator : Generator
//    func generate() -> GeneratorType
//}
//


//xPoint = 147806593.422222
//MaxX = 147958397.15555555
//Return point = 154.576
//size.width = 375






//startTreeDemo(arr: Array<Array<TreeData>>, index: Int)

//        var lastControl = 0.0 //Double(self.view.frame.size.height/2)
//        for dataStruct in tree.testData {
//
//            lastControl = animateLineAtAxis(dataStruct, Last: lastControl)
//        }
//self.view.bounds.origin = CGPoint(x: 100, y: 100)
//self.view.bounds = CGRect(x: 300, y: 600, width: 50, height: 20)

//tree.querySectionWith(testPoint, Query: MKMapRectMake(0, 0, 50, 50), Root: tree.rootNode);


//    func determineQueryArea(screenView: UIView) -> MKMapRect {
//
//        //var qView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 50, height: 50))
//        //qView.center = CGPoint(x: Double(self.view.frame.size.width / 2.0), y: Double(self.view.frame.size.height/2.0))
//
//        let xMin = CGRectGetMinX(screenView.frame)
//        let xMax = CGRectGetMaxX(screenView.frame)
//        let yMin = CGRectGetMinY(screenView.frame)
//        let yMax = CGRectGetMaxY(screenView.frame)
//
//        let xMinMap = XmapPointFromScreenPoint(xMin, maxX: self.view.frame.size.width, maxMapX: maxX)
//        let xMaxMap = XmapPointFromScreenPoint(xMax, maxX: self.view.frame.size.width, maxMapX: maxX)
//        let yMinMap = YmapPointFromScreenPoint(yMin, maxY: self.view.frame.size.height, maxMapY: maxY)
//        let yMaxMap = YmapPointFromScreenPoint(yMax, maxY: self.view.frame.size.height, maxMapY: maxY)
//
//        //p1 (xMin, yMin) p2 (xMax, yMin)
//        //p3 (xMin, yMin) p4 (xMin, yMax)
//
//        let xLength = sqrt(pow(abs(xMinMap - xMaxMap), 2) + pow(abs(yMinMap - yMinMap), 2))
//        let yLength = sqrt(pow(abs(xMinMap - xMinMap), 2) + pow(abs(yMinMap - yMaxMap), 2))
//
//        //print(self.queryArea.frame.size.width, self.screenView.frame.size.height, xLength, yLength)
//        return MKMapRectMake(xMinMap, yMinMap, yLength, xLength)
//
//    }



