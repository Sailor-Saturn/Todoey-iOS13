//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var items = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    let dataFilePath =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist ")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
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
                
                let item = Item(context: self.context) //textField.text!
                item.title = textField.text!
                item.done = false
                item.parentCategory = self.selectedCategory
                self.items.append(item)
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
        do {
            try context.save()
        } catch {
            print("Error saving \(error).")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), and predicate: NSPredicate? = nil ) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        let compoundPredicate: NSCompoundPredicate

        if let predicate = predicate {
            compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate,categoryPredicate])
        }else {
            compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate])
        }
        
        request.predicate = compoundPredicate
        do {
            items = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    
}

// MARK: Search Bar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS %@[cd]", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        loadItems(with: request, and: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
           
        }
    }
}

