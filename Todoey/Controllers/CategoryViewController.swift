import UIKit
import RealmSwift
//import Chameleons

class CategoryViewController: SwipeTableViewController {
    
    //MARK: - 全局变量
    let realm = try! Realm()
    
    var categories:Results<CategoryTitle>?
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
                
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories added yet."
        
        //从数据库提取颜色
        guard let cellColor = UIColor(hexString: categories?[indexPath.row].colorString ?? "32ADE6") else {fatalError("No color")}
        
        cell.backgroundColor = cellColor
        
        //字体反色
        cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: cellColor, isFlat: true)
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories?[indexPath.row]
            
        }
        
        
    }
    
    
    //MARK: - Data Manipulation Methods
    func save(category: CategoryTitle){
        do{
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Error Saving CategoryTitles \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories(){
        
        categories = realm.objects(CategoryTitle.self)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete Data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(categoryForDeletion)
                }
            }catch{
                print("Error saving done status, \(error)")
            }
        }
    }
    
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default)
            { (action) in
                
                let newCategory = CategoryTitle()
                
                newCategory.name = textField.text!
                
                newCategory.colorString = UIColor.randomFlat().hexValue()
                
                //保存颜色到数据库
                self.save(category: newCategory)
                
            }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true)
        
    }
    
}
