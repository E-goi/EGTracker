//
//  EGTrackerRequest+CoreDataProperties.swift
//  TinyGoi
//
//  Created by Miguel Chaves on 26/02/16.
//  Copyright © 2016 E-Goi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension EGTrackerRequest {

    @NSManaged var url: String?
    @NSManaged var sent: NSNumber?
    @NSManaged var date: NSDate?
}
