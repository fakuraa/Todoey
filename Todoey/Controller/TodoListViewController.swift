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

    @IBOutlet weak var searchBar: UISearchBar!
    var todoItems : Results<Item>?
    let realm = try! Realm()
    let context = (UIApplication.shared.delegate as! AppDelegate).presistentCoontainer.viewContext
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
        
//    let defaults = UserDefaults.standard
//    let key = "TodoList"
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colorHex = selectedCategory?.color {
            title = selectedCategory!.name
            let bgColor = UIColor(hexString: colorHex)!
            let tintColor = ContrastColorOf(bgColor, returnFlat: true)
            
            searchBar.searchTextField.borderStyle = .none
            searchBar.searchTextField.backgroundColor = .white
            searchBar.barTintColor = bgColor
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
            
            navBar.tintColor = tintColor
            navBar.scrollEdgeAppearance?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : tintColor]
            navBar.scrollEdgeAppearance?.backgroundColor = bgColor
            navBar.scrollEdgeAppearance?.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : tintColor]
            navBar.standardAppearance = navBar.scrollEdgeAppearance!
        }
    }
    
    @IBAction func addOnClick(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default){ action in
            if let cat = self.selectedCategory{
                do{
                    try self.realm.write{
                        let newItem  = Item()
                        newItem.title = textField.text ?? ""
                        newItem.dateCreated = Date()
                        cat.items.append(newItem)
                    }
                }catch{
                    print("Error saving new items, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView Data Source Method
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = todoItems?[indexPath.row].title
        cell.accessoryType = todoItems?[indexPath.row].done == true ? .checkmark : .none
        cell.backgroundColor = UIColor(hexString: selectedCategory?.color ?? FlatSkyBlue().hexValue())!.darken(byPercentage:CGFloat(indexPath.row) / CGFloat(todoItems!.count)
        )
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let data = todoItems?[indexPath.row]{
//            deleteItems(item: data)
            do{
                try realm.write{
                    data.done = !data.done
                }
            }catch{
                print("Error Saving done status, \(error)")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    override func deleteItem(at row: Int) {
        if let data = todoItems?[row]{
            do{
                try realm.write{
                    realm.delete(data)
                }
            }catch{
                print("Error Deleting data, \(error)")
            }
        }
    }
    
    func saveItems(item:Item){
//        let encoder = PropertyListEncoder() //MARK: - Plist Data (1)
        do{
//            let data = try encoder.encode(itemArray) //MARK: - Plist Data (2)
//            try data.write(to: dataFilePath!) //MARK: - Plist Data (3)
//            try context.save() //MARK: - Core Data
            try realm.write{
                realm.add(item)
            }
        }catch{
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems(){
        //MARK: - Realm Load data
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
        
        //MARK: - PLIST data
//        if let data = try? Data(contentsOf: dataFilePath!){
//            let decoder = PropertyListDecoder()
//            do{
//            itemArray = try decoder.decode([Item].self, from: data)
//            }catch{
//                print("Error decoding item array, \(error)")
//            }
//        }
        //MARK: - Core data
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory?.name ?? "")
//        if let addtionalPredicates = predicates {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicates])
//        }else{
//            request.predicate = categoryPredicate
//        }
//        
//        
//        do{
//            itemArray = try context.fetch(request)
//            tableView.reloadData()
//        }catch{
//            print("Error fetching data from context \(error)")
//        }
    }
    
}


//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //MARK: - Realm Search
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
        //MARK: - Core data search
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text ?? "")
//        
//        request.predicate = predicate
//         
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//        loadItems(with: request, predicates: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            DispatchQueue.main.async {
                self.loadItems()
                searchBar.resignFirstResponder()
            }
            
        }
    }
}

