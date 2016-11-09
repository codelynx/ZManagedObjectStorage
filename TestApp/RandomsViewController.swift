//
//	ViewController.swift
//	TestApp
//
//	Created by Kaz Yoshikawa on 11/9/16.
//
//

import UIKit
import CoreData

class RandomsViewController: UIViewController, UITableViewDataSource {

	@IBOutlet weak var tableView: UITableView!

	// MARK: -

	lazy var storage: ZManagedObjectStorage = {
		return ZManagedObjectStorage(fileURL: self.documentFileURL, modelName: "Randoms")!
	}()

	var objects = [RandomObject]()

	func fetchObjects() -> [RandomObject] {
		let request = NSFetchRequest<RandomObject>(entityName: "RandomObject")
		request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
		return try! self.storage.managedObjectContext.fetch(request)
	}

	var documentFileURL: URL {
		let directoryURL: URL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		return directoryURL.appendingPathComponent("randoms.sqlite")
	}

	// MARK: -

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.objects = self.fetchObjects()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: -
	
	@IBAction func addAction(_ sender: AnyObject) {
		let context = self.storage.managedObjectContext
		if let entity = NSEntityDescription.entity(forEntityName: "RandomObject", in: context),
		   let object = NSManagedObject(entity: entity, insertInto: context) as? RandomObject {
			object.date = Date() as NSDate?
			object.value = Int32(bitPattern: arc4random())
			self.objects.append(object)
			try? self.storage.save()
			self.tableView.reloadData()
		}
	}

	@IBAction func wasteAction(_ sender: AnyObject) {
		let context = self.storage.managedObjectContext
		for object in self.objects {
			context.delete(object)
		}
		try? context.save()
		self.objects = fetchObjects()
		self.tableView.reloadData()
	}

	// MARK: -
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.objects.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let object = self.objects[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = String(format: "0x%08x", Int(object.value))
		cell.detailTextLabel?.text = object.date?.description
		return cell
	}
	
}




