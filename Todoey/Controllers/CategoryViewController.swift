//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Vera Dias on 07/06/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()
    var categories: Results<Category>?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        loadCategories()
        tableView.separatorStyle = .none
    }

   
    // MARK: TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            guard let definedColor = UIColor(hexString: category.color) else {
                fatalError()
            }
            cell.backgroundColor = definedColor
            cell.textLabel?.textColor = ContrastColorOf(definedColor, returnFlat: true)
        }
        

        return cell
    }

    // MARK: Data Manipulation Methods

    func save(with category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving \(error).")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories() {

        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    // MARK: Delete Categories
    override func updateModel(at indexPath: IndexPath) {
        if let category = categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(category)
                }
            }catch {
                print("Error deleting categories \(error).")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation Controller does not exist.")
        }
        
        let bar = UINavigationBarAppearance()

        bar.backgroundColor = UIColor(hexString: "1D9BF6")

        navBar.standardAppearance = bar

        navBar.compactAppearance = bar

        navBar.scrollEdgeAppearance = bar
        
        navBar.backgroundColor = UIColor(hexString: "1D9BF6")

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
                
                let category = Category()
                category.name = textField.text!
                category.color = UIColor.randomFlat().hexValue()
                self.save(with: category)

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
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
}

