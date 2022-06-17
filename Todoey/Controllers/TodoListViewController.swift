//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    let realm = try! Realm()
    var items: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedCategory = selectedCategory {
            
            title = selectedCategory.name
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation Controller does not exist.")
            }
            let newColor = UIColor(hexString: selectedCategory.color)
            
            let bar = UINavigationBarAppearance()

            bar.backgroundColor = newColor

            navBar.standardAppearance = bar

            navBar.compactAppearance = bar

            navBar.scrollEdgeAppearance = bar
            
            if let color = newColor {
                navBar.tintColor = ContrastColorOf(color, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:
                                                   ContrastColorOf(color, returnFlat: true)]
            }
            
            searchBar.barTintColor = newColor
            searchBar.searchTextField.backgroundColor = FlatWhite()
        }
    }

    // MARK: TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = items?[indexPath.row],
           let category = selectedCategory,
           let categoryColor = UIColor(hexString: category.color){
            cell.textLabel?.text = item.title
            if let color = categoryColor.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(items!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added yet."
        }
        
        return cell
    }
    
    // MARK: Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    // How to delete
                    // realm.delete(item)
                    item.done = !item.done
                }
            }catch {
                print("Error saving done status \(error).")
            }
        }

        tableView.reloadData()
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
                if let selectedCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let item = Item()
                            item.title = textField.text!
                            item.done = false
                            item.dateCreated = Date()
                            selectedCategory.items.append(item)
                        }
                    } catch {
                        print("Error saving new items \(error).")
                    }
                }
                self.tableView.reloadData()
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
    
    func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
    }
    
    //MARK: Delete items
    override func updateModel(at indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            }catch {
                print("Error deleting items \(error).")
            }
        }
    }
}

// MARK: Search Bar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        items = items?
            .filter("title contains [cd] %@", searchBar.text!)
            .sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData() 
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

