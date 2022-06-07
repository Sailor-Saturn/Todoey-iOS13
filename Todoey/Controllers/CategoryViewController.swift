//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Vera Dias on 07/06/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }

   
    // MARK: TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryItemCell", for: indexPath)
        
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name

        return cell
    }

    // MARK: Data Manipulation Methods

    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving \(error).")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Category> = Category.fetchRequest()) {

        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    // MARK: Add new Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(
            title: "Add New Category",
            message: "",
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: "Add Category",
            style: .default) { (action) in
                
                let category = Category(context: self.context)
                category.name = textField.text!
                self.categories.append(category)
                self.saveItems()

            }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category."
            textField = alertTextField
        }

        alert.addAction(action)

        present(alert,
                animated: true,
                completion: nil)
    }
    
    
    // MARK: TableView Delegate  Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
    
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
}
