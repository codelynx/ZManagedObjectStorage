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


public class ZManagedObjectStorage {

	public private(set) var fileURL: URL
	public private(set) var modelName: String
	public let managedObjectModel: NSManagedObjectModel
	public let persistentStoreCoordinator: NSPersistentStoreCoordinator
	public let persistentStore: NSPersistentStore
	public let managedObjectContext: NSManagedObjectContext

	public init?(fileURL: URL, modelName: String) {
		self.fileURL = fileURL
		self.modelName = modelName

		// object model
		guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else { return nil }
		guard let model = NSManagedObjectModel(contentsOf: modelURL) else { return nil }
		self.managedObjectModel = model

		// persistent store coordinator
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
		self.persistentStoreCoordinator = coordinator

		let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true];
		do {
			self.persistentStore = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: fileURL, options:options)
		}
		catch {
			print("ZManagedObjectStorage: \(error)\r  file: \(fileURL.path)")
			#if DEBUG
			do {
				print("ZManagedObjectStorage: Failed migrating Core Data Model. Old storage will be deleted in debug build.")
				print("  file: \(fileURL.path)")
				try FileManager.default.removeItem(at: fileURL)
				// recreate store file once again
				self.persistentStore = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: fileURL, options: options)
			}
			catch { print(error) ; return nil }
			#endif
		}

		// managed object context
		let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		context.persistentStoreCoordinator = coordinator
		self.managedObjectContext = context
	}

	func insert<T: NSManagedObject>(entityName: String) -> T? {
		let context = self.managedObjectContext
		if let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) {
			return NSManagedObject(entity: entity, insertInto: context) as? T
		}
		return nil
	}

	func save() throws {
		try self.managedObjectContext.save()
	}
}
