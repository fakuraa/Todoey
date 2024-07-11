//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Fadil Kurniawan on 09/07/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categories : Results<Category>?
    let context = (UIApplication.shared.delegate as! AppDelegate).presistentCoontainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
        let bgColor = FlatSkyBlue()
        let tintColor = ContrastColorOf(bgColor, returnFlat: true)
        
        navBar.tintColor = tintColor
        navBar.scrollEdgeAppearance?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : tintColor]
        navBar.scrollEdgeAppearance?.backgroundColor = bgColor
        navBar.scrollEdgeAppearance?.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : tintColor]
        
        navBar.standardAppearance = navBar.scrollEdgeAppearance!
    
    }
    
    //MARK: - TableView - Add New Category
    @IBAction func OnAddClick(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default){ action in
            let newItem  = Category()
            newItem.name = textField.text ?? ""
            newItem.color = UIColor.randomFlat().hexValue()
//            self.categories.append(newItem)
            self.saveData(category: newItem)
            
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView,cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added"
        cell.backgroundColor = UIColor(hexString: categories?[indexPath.row].color ?? UIColor.randomFlat().hexValue())
        
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - TableView Manipulation
    func loadData(){
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    func saveData(category:Category){
        do{
            try realm.write{
                realm.add(category)
            }
        }catch{
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
        
    override func deleteItem(at row: Int) {
        super.deleteItem(at: row)
        if let data = categories?[row]{
            do{
                try realm.write{
                    realm.delete(data)
                }
            }catch{
                print("Error Deleting data, \(error)")
            }
        }
    }
    
}


