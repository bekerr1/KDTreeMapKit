//
//  PointParser.swift
//  KDTreeMapKit
//
//  Created by brendan kerr on 3/8/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class PointParser {
    
    
    var dataFile: NSData?
    var dataFileURL: NSURL?

    var CLLocationPoints = [MKMapPoint]()
    var stringLocations = [NSString]()
    
    init() {
        
    }
    
    func parseData() {
        
        
        let dataURL = NSBundle.mainBundle().URLForResource("zipcode2", withExtension: "csv")
        if let data = NSData(contentsOfURL: dataURL!) {
            if let content = NSString(data: data, encoding: NSUTF8StringEncoding) {
                
                let lines: [String] = content.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()) as [String]
                var dex = 0
                var lastString: NSString = ""
                for line in lines {                  
                    var contents = [String]()
                    contents = line.componentsSeparatedByString(",")
                    if let dataPointLong = Float(contents.removeAtIndex(3)) {
                        if let dataPointLat = Float(contents.removeAtIndex(3)) {
                            
                            let newString = contents.removeAtIndex(1)
                            if newString != lastString && (dataPointLong > 17 && dataPointLong < 19 && dataPointLat > -66 && dataPointLat < -65) {
                                lastString = newString
                                
                                stringLocations.append(lastString)
                                
                                let mapPoint = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: Double(dataPointLat), longitude: Double(dataPointLong)))
                                if mapPoint.x > 0 && mapPoint.y > 0 {
                                    CLLocationPoints.append(mapPoint)
                                }
                                

                                
                            }
                            
                            
                            
                            dex++
                        }
                        
                    } else {
                        //print("Not a valid data point")
                    }
                    
                    if CLLocationPoints.count > 29 {
                        break
                    }
                }
            }
        }
        
    }
}

extension Array where Element : Hashable {
    var unique: [Element] {
        return Array(Set(self))
    }
}

extension MKMapPoint : Hashable, Equatable {
    public var hashValue: Int {
        return Int(floor(x))
    }
}

public func ==(lhs: MKMapPoint, rhs: MKMapPoint) -> Bool {
    return xequals(lhs.x, rhs: rhs.x) || yequals(lhs.y, rhs: rhs.y)
}

public func xequals(lhs: Double, rhs: Double) -> Bool {
    return lhs == rhs
}

public func yequals(lhs: Double, rhs: Double) -> Bool {
    return lhs == rhs
}


//NSArray *components = [line componentsSeparatedByString:@","];
//    double latitude = [components[1] doubleValue];
//    double longitude = [components[0] doubleValue];
//
//    TBHotelInfo* hotelInfo = malloc(sizeof(TBHotelInfo));
//
//    NSString *hotelName = [components[2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    hotelInfo->hotelName = malloc(sizeof(char) * hotelName.length + 1);
//    strncpy(hotelInfo->hotelName, [hotelName UTF8String], hotelName.length + 1);
//
//    NSString *hotelPhoneNumber = [[components lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    hotelInfo->hotelPhoneNumber = malloc(sizeof(char) * hotelPhoneNumber.length + 1);
//    strncpy(hotelInfo->hotelPhoneNumber, [hotelPhoneNumber UTF8String], hotelPhoneNumber.length + 1);
//
//    return TBQuadTreeNodeDataMake(latitude, longitude, hotelInfo);
//}
// NSString *data = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"USA-HotelMotel" ofType:@"csv"] encoding:NSASCIIStringEncoding error:nil];
//        NSArray *lines = [data componentsSeparatedByString:@"\n"];
//
//        NSInteger count = lines.count - 1;
//
//        TBQuadTreeNodeData *dataArray = malloc(sizeof(TBQuadTreeNodeData) * count);
//        for (NSInteger i = 0; i < count; i++) {
//                dataArray[i] = TBDataFromLine(lines[i]);