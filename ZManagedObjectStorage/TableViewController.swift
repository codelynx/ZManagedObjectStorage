//
//  TableTableViewController.swift
//  ZManagedObjectStorage
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

import UIKit
import CoreData


class TableViewController: UITableViewController {

	var items = [UInt]()

	var documentDirectory: String {
		return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
	}
	
	lazy var documentStorage: ZManagedObjectStorage = {
		let documentPath = (self.documentDirectory as NSString).stringByAppendingPathComponent("document.sqlite")
		return ZManagedObjectStorage(fileURL: NSURL(fileURLWithPath: documentPath), modelName: "MyModel")!
	}()

	lazy var managedObjectContext: NSManagedObjectContext = {
		return self.documentStorage.managedObjectContext!
	}()

    override func viewDidLoad() {
        super.viewDidLoad()

		let fetchRequest = NSFetchRequest()
		let entityDescription = NSEntityDescription.entityForName("Item", inManagedObjectContext: self.managedObjectContext)
		fetchRequest.entity = entityDescription
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
		do {
			let objects: [NSNumber] = try managedObjectContext.executeFetchRequest(fetchRequest).flatMap { $0 as? Item }.flatMap { $0.value }
			self.items = objects.map { $0.unsignedIntegerValue }
		}
		catch let error {
			print("\(error)")
		}
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.navigationBarHidden = false
		typealias T = TableViewController
		self.title = "Random Number Generator"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(T.addAction))
		self.tableView.reloadData()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	// MARK: -

	@IBAction func addAction(sender: AnyObject) {
		let value = arc4random_uniform(1_000_000)
		let managedObject = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: self.managedObjectContext)
		let valueObject = managedObject as! Item
		valueObject.value = NSNumber(unsignedInt: value)
		self.items.append(UInt(value))
		do {
			try self.managedObjectContext.save()
		}
		catch let error { print("\(error)") }
		self.tableView.reloadData()
	}

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let value = items[indexPath.row]
		let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
		cell.textLabel?.text = String(value)
        return cell
    }

}
