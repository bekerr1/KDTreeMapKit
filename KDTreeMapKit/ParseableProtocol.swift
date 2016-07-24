//
//  ParseableProtocol.swift
//  KDTreeMapKit
//
//  Created by brendan kerr on 6/7/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import Foundation


protocol Parseable  {
    
    var dataFileURL: NSURL {get set}
    var dataFile: NSData {get set}
    var data: [AnyObject] {get set}
    var dataAsString: [String] {get set}
    
    func retrieveDataFrom(dataFile: NSURL) -> [AnyObject]
    func retrieveDataAsStringArrayFrom(dataFile: NSURL) -> [String]
}



//let dataURL = NSBundle.mainBundle().URLForResource("zipcode2", withExtension: "csv")
//if let data = NSData(contentsOfURL: dataURL!) {
//    if let content = NSString(data: data, encoding: NSUTF8StringEncoding) {
//        
//        let lines: [String] = content.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()) as [String]
//        var dex = 0
//        var lastString: NSString = ""
//        for line in lines {
//            var contents = [String]()
//            contents = line.componentsSeparatedByString(",")
//            {
//    {
//{