//
//  EGExtentions.swift
//  Pods
//
//  Created by Miguel Chaves on 01/04/16.
//
//

import UIKit
import CoreData

extension NSManagedObject {
    
    class func entityName() -> String {
        
        let classString = NSStringFromClass(self)
        let components = classString.componentsSeparatedByString(".")
        return components.last ?? classString
    }
}
