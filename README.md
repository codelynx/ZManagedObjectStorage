![swift](https://img.shields.io/badge/swift-3.0-orange.svg) ![license](https://img.shields.io/badge/license-MIT-yellow.svg)

# ZManagedObjectStorage


ZManagedObjectStorage is a utility class for Core Data programmers.  ZManagedObjectStorage creates and manage a single
core data persistent storage from single model, and client code does not have to worry about constructing NSManagedObjectModel,
NSPersistentStoreCoordinator and NSManagedObjectContext.


## How to use it?

Construct `ZManagedObjectStorage` class with document URL and model name.  `ZManagedObjectStorage` manages `NSPersistentStoreCoordinator`
and `NSManagedObjectContext` in the class.  When the document does not exist at given path, the document is created automatically.  You don't have to worry about preparing persistent store coordinator and managed object context, they are prepared by `ZManagedObjectStorage`.


Here is the example of how to set up storage with a file in document directory.

```.swift
let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
let documentPath = (self.documentDirectory as NSString).appendingPathComponent("document.sqlite")
let storage = ZManagedObjectStorage(fileURL: URL(fileURLWithPath: documentPath), modelName: "MyModel")!
```

## Reading objects from Core Data

Here is the typical way to fetch objects from core data.  `ZManagedObjectStorage` provides `managedObjectContext` property and rest of the code should be the same as typical core data code.

```.swift
do {
	if	let context = storage.managedObjectContext {
		let request = NSFetchRequest<MyObject>(entityName: "MyObject")
		request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
		let objects = try context.fetch(request)
		// ...
	}
}
catch { print("\(error)") }
```

## Inserting an object into Core data

Here is the typical code to insert an object into Core Data.  As you can see, it just get managed object context from storage object and nothing special for the rest of the code.

```.swift
if	let context = storage.managedObjectContext,
	let entity = NSEntityDescription.entity(forEntityName: "MyObject", in: context),
	let object = NSManagedObject(entity: entity, insertInto: context) as? MyObject {
	// ...
}
catch { print("\(error)") }
```

## Sample Code: Random number generator

This sample code demonstrate how to use `ZManagedObjectStorage`.  When you launch the app, it creates the core data document using `ZManagedObjectStorage` and display `TableViewController`.  Then when you tap on `+` button, it generates random number with time stamp, and show it on table view.  All generated numbers are saved as Core Data object, and they are loaded when app is launched next time.  The app is not much useful but it is a living example of using `ZManagedObjectStorage`.


## Versions

```.log
Xcode Version 8.1 (8B62)
Apple Swift version 3.0.1 (swiftlang-800.0.58.6 clang-800.0.42.1)
```

## License

The MIT license.

