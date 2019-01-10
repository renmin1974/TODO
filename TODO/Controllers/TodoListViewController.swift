//
//  ViewController.swift
//  TODO
//
//  Created by 任民 on 2019/1/4.
//  Copyright © 2019年 任民ORG. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
//    let defaults = UserDefaults.standard
    var itemArray = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        loadItems()
        //再增加117个新项目
//        for index  in 4...20 {
//            let newItem = Item()
//            newItem.title = "第\(index)件事务"
//            itemArray.append(newItem)
//        }
        
        // Do any additional setup after loading the view, typically from a nib.
//        if let items = defaults.array(forKey: "ToDoListArray") as? [String] {
//            itemArray = items
//        }
    }

    //Mark: - Table view datasource methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        let item = itemArray[indexPath.row]
        cell.accessoryType = item.done ? .checkmark : .none
        
//        if itemArray[indexPath.row].done == false {
//            cell.accessoryType = .none
//        } else {
//            cell.accessoryType = .checkmark
//        }
        print("更新第：\(indexPath.row)行")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    //Mark: - Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
//        let title = itemArray[indexPath.row].title
//        itemArray[indexPath.row].setValue(title! + " - (已完成)", forKey: "title")
        
        saveItems()
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
        tableView.endUpdates()

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //Mark: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "添加一个新的ToDo项目", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "添加项目", style: .default) {(action) in
            // 用户单击后要执行的代码
            
            
            let newItem = Item(context: self.context)
            
            newItem.title = textField.text!
            newItem.done = false
            //将selectedCategory的值赋给Item对象的parentCategory关系属性
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            self.saveItems()
            
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "创建一个新项目"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems(){
        do {
            try context.save()
        } catch {
            print("保存context错误：\(error)")
        }
        
        self.tableView.reloadData()

    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("从context获取数据错误：\(error)")
        }
        
        tableView.reloadData()
    }
    
}

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[C] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
