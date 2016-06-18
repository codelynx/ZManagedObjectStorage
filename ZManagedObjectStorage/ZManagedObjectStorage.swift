//
//	ZManagedObjectStorage.swift
//	ZKit
//
//	The MIT License (MIT)
//
//	Copyright (c) 2016 Electricwoods LLC, Kaz Yoshikawa.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy 
//	of this software and associated documentation files (the "Software"), to deal 
//	in the Software without restriction, including without limitation the rights 
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
//	copies of the Software, and to permit persons to whom the Software is 
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in 
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.


import Foundation
import CoreData


class ZManagedObjectStorage {

	var fileURL: NSURL
	var modelName: String

	init?(fileURL: NSURL, modelName: String) {
		self.fileURL = fileURL
		self.modelName = modelName
		if self.managedObjectContext == nil {
			return nil
		}
	}
	
	lazy var managedObjectModel: NSManagedObjectModel? = {
		var managedObjectModel: NSManagedObjectModel? = nil
		let modelURL = NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")
		if  modelURL != nil {
			managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
		}
		if managedObjectModel == nil { NSLog("model not found: name=%@", self.modelName) }
		return managedObjectModel
	}()

	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
		var coordinator: NSPersistentStoreCoordinator? = nil
		var error: NSError? = nil

		var managedObjectModel = self.managedObjectModel
		if (managedObjectModel != nil) {

			do {
				coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
				let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true];
				let store = try coordinator?.addPersistentStoreWithType(NSSQLiteStoreType,
							configuration:nil, URL:self.fileURL, options:options)
				if store == nil {
					NSLog("Failed migrating Core Data Model. Old file will be deleted.")
					NSLog("file: %@", self.fileURL.path!)

					#if DEBUG
					NSFileManager.defaultManager().removeItemAtPath(self.file, error: &error)
					ZReportError(error)
					// recreate store file once again
					store = coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
								configuration:nil, URL:self.storeURL, options:options, error:&error)
					ZReportError(error)
					if store == nil { return nil }
					#endif
				}
			}
			catch let error {
			}
		}
		if coordinator == nil {
			NSLog("failed to configure persistent store coodinator: %@", self.fileURL.path!)
		}
		return coordinator
	}()

	lazy var managedObjectContext: NSManagedObjectContext? = {
		var context: NSManagedObjectContext? = nil
		let coordinator = self.persistentStoreCoordinator
		if coordinator != nil {
			context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
			context?.persistentStoreCoordinator = self.persistentStoreCoordinator
		}
		return context
	}()

}
