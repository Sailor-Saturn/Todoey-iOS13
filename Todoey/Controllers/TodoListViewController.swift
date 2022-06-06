//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var items = [Item]()
    let dataFilePath =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist ")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadItems()
        
//        if let itemsArray = defaults.dictionary(forKey: "TodoListArray") as? [String:Bool] {
//            items = itemsArray.map({ (key: String, value: Bool) in
//                Item(title:key, done:value)
//            })
//        }
    }

    // MARK: TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        
        
        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }
    
    // MARK: Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(items[indexPath.row])
        items[indexPath.row].done = !items[indexPath.row].done
        
        saveItems()

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(
            title: "Add New Todoey Item",
            message: "",
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: "Add Item",
            style: .default) { (action) in
                self.items.append(Item(title: textField.text!))
                self.saveItems()

            }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new task."
            textField = alertTextField
        }

        alert.addAction(action)

        present(alert,
                animated: true,
                completion: nil)
    }
    
    func saveItems() {
        let enconder = PropertyListEncoder()
        do {
            let data = try enconder.encode(items)
            try data.write(to:  dataFilePath!)
        } catch {
            print("error encoding array")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                items = try decoder.decode([Item].self, from: data)
            } catch {
                print("error decoding item array")
            }
            
        }
        
    }
    
}

