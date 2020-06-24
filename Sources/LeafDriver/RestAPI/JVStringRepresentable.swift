//
//  File.swift
//  
//
//  Created by Jan Verrept on 04/05/2020.
//

import Foundation

public protocol StringRepresentable { var stringValue:String{get} }

public extension StringRepresentable where Self:RawRepresentable, Self.RawValue == String{
     var stringValue:String{
        return self.rawValue as String
    }
}

public extension StringRepresentable where Self:StringProtocol {
     var stringValue:String{
        return String(describing: self)
    }
}

public protocol StringRepresentableEnum: StringRepresentable & RawRepresentable & Hashable {}
