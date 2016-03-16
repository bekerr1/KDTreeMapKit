//
//  Casting.swift
//  KDTreeMapKit
//
//  Created by brendan kerr on 3/8/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import Foundation
import UIKit


protocol NumberConvertible {
    init (_ value: Int)
    init (_ value: Float)
    init (_ value: Double)
    init (_ value: CGFloat)
}

extension CGFloat : NumberConvertible {}
extension Double  : NumberConvertible {}
extension Float   : NumberConvertible {}
extension Int     : NumberConvertible {}

extension CGFloat{
    public  init(_ value: CGFloat){
        self = value
    }
}


extension NumberConvertible {
    
    internal func convert<T: NumberConvertible>() -> T {
        switch self {
        case let x as CGFloat:
            return T(x) //T.init(x)
        case let x as Float:
            return T(x)
        case let x as Double:
            return T(x)
        case let x as Int:
            return T(x)
        default:
            assert(false, "NumberConvertible convert cast failed!")
            return T(0)
        }
    }
    internal var c:CGFloat{
        return convert()
    }
    //...
}


extension NumberConvertible {
    internal typealias CombineType = (Double,Double) -> Double
    internal func operate<T:NumberConvertible,V:NumberConvertible>(b:T, @noescape combine:CombineType) -> V{
        let x:Double = self.convert()
        let y:Double = b.convert()
        return combine(x,y).convert()
    }
}

private func + <T:NumberConvertible, U:NumberConvertible, V:NumberConvertible>(lhs: T, rhs: U) -> V {
    return lhs.operate(rhs, combine: + )
}
private func - <T:NumberConvertible, U:NumberConvertible,V:NumberConvertible>(lhs: T, rhs: U) -> V {
    return lhs.operate(rhs, combine: - )
}
private func / <T:NumberConvertible, U:NumberConvertible, V:NumberConvertible>(lhs: T, rhs: U) -> V {
    return lhs.operate(rhs, combine: / )
}



