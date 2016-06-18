# ZManagedObjectStorage

ZManagedObjectStorage is a utility class for Core Data programmers.  ZManagedObjectStorage creates and manage a single
core data persistent storage from single model, and client code does not have to worry about constructing NSManagedObjectModel,
NSPersistentStoreCoordinator and NSManagedObjectContext.

### How to use it?

Construct `ZManagedObjectStorage` class with document URL and model name.  `ZManagedObjectStorage` manages `NSPersistentStoreCoordinator`
and `NSManagedObjectContext` in the class.  When the document does not exist at given path, the document is created automatically.  You don't have to worry about preparing persistent store coordinator and managed object context, they are prepared by `ZManagedObjectStorage`.


Here is the example of how to set up storage with a file in document directory.

```.swift
let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
let documentPath = (documentDirectory as NSString).stringByAppendingPathComponent("document.sqlite")
let documentURL = NSURL(fileURLWithPath: documentPath)
let storage = ZManagedObjectStorage(fileURL: documentURL, modelName: "MyModel")!
```

### Reading objects from Core Data

Here is the typical way to fetch objects from core data.  `ZManagedObjectStorage` provides `managedObjectContext` property and rest of the code should be the same as typical core data code.

```.swift
let managedObjectContext = storage.managedObjectContext
do {
	let fetchRequest = NSFetchRequest()
	let entityDescription = NSEntityDescription.entityForName("YourEntity", inManagedObjectContext: managedObjectContext)
	fetchRequest.entity = entityDescription
	fetchRequest.sortDescriptors = [NSSortDescriptor(key: "some_key", ascending: true)]
	let objects = try managedObjectContext.executeFetchRequest(fetchRequest)
	// ...
}
catch let error {
	print("\(error)")
}
```

### Inserting an object into Core data

Here is the typical code to insert an object into Core Data.  As you can see, it just get managed object context from storage object and nothing special for the rest of the code.

```.swift
let managedObjectContext = storage.managedObjectContext
do {
	let managedObject = NSEntityDescription.insertNewObjectForEntityForName("YourEntity", inManagedObjectContext: managedObjectContext)
	try managedObject.save()
}
catch let error {
	print("\(error)")
}
```

### Sample Code: Random number generator

This sample code demonstrate how to use `ZManagedObjectStorage`.  When you launch the app, it creates the core data document using `ZManagedObjectStorage` and display `TableViewController`.  Then when you tap on `+` button, it generates random number with time stamp, and show it on table view.  All generated numbers are saved as Core Data object, and they are loaded when app is launched next time.  The app is not much useful but it is a living example of using `ZManagedObjectStorage`.


### Swift Version

```
Apple Swift version 2.2 (swiftlang-703.0.18.1 clang-703.0.29)
```

### License

The MIT license.

