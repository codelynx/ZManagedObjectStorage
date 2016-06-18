//
//  Item.swift
//  ZManagedObjectStorage
//
//  Created by Kaz Yoshikawa on 6/18/16.
//  Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import Foundation
import CoreData

@objc(Item)
class Item: NSManagedObject {

	override func awakeFromInsert() {
		super.awakeFromInsert()
		self.date = NSDate()
	}

}
