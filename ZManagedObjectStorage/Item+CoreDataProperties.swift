//
//  Item+CoreDataProperties.swift
//  ZManagedObjectStorage
//
//  Created by Kaz Yoshikawa on 6/18/16.
//  Copyright © 2016 Electricwoods LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Item {

    @NSManaged var value: NSNumber?
    @NSManaged var date: NSDate?

}
