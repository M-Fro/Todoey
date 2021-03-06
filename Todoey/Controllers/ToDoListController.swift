//
//  ViewController.swift
//  Todoey
//
//  Created by Mihails Frolovs on 30/11/2018.
//  Copyright © 2018 Mihails Frolovs. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListController: UITableViewController {
    
    var todoItems : Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet {
       loadItems()
            
        }
    }
    
    var number = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
     
        
          }
    
    
    //MARK: Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row] {
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    //MARK: TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status \(error)")
            }
            
            tableView.reloadData()
            
        }
        
        
//        todoItems[indexPath.row].done = !todoItems[indexPath.row].done
        
    
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    //MARK: Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add New Item", style: .default) { (action) in
            //what will happen once theuser clicks the add item
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.date = Date()
                        currentCategory.items.append(newItem)
                       
                    }
                } catch {
                    print("error savingitems, \(error)")
                }
            }
            
            self.tableView.reloadData()
            
            
            }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil )
    }
    
    
    func loadItems() {

        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }


}
//MARK: - Search button
extension ToDoListController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
        todoItems = todoItems?.filter("title CONTAINS[cd] &@", searchBar.text!).sorted(byKeyPath: "date", ascending: true)
        
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

