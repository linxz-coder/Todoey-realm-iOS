import UIKit
import RealmSwift
import Chameleon

class TodoListViewController: SwipeTableViewController {
    
    //MARK: - 全局变量
    var todoItems : Results<Item>?
    
    let realm = try! Realm()
    
    var selectedCategory : CategoryTitle? {
        didSet{
            loadItems()
        }
    }
    
    var defaultAppearance: UINavigationBarAppearance?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //改变导航条颜色
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.colorString {
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
            
            guard let menuColor = UIColor(hexString: colorHex) else {
                fatalError("Error color")}
            
            // 保存默认外观配置，以便后续恢复
            defaultAppearance = navBar.standardAppearance.copy()
            
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor(hexString: colorHex)
            
            //改变back按钮颜色
            navBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: menuColor , isFlat: true)
            
            //改变标题颜色
            appearance.titleTextAttributes = [.foregroundColor: UIColor(contrastingBlackOrWhiteColorOn: menuColor, isFlat: true)]
            
            // 设置 Large Title 的颜色
              appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(contrastingBlackOrWhiteColorOn: menuColor, isFlat: true)]
            
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            

            
            searchBar.barTintColor = UIColor(hexString: colorHex)
        }
    }
    
    //恢复导航条颜色
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 恢复默认外观
        if let defaultAppearance = defaultAppearance,
           let navBar = navigationController?.navigationBar {
            navBar.standardAppearance = defaultAppearance
            navBar.scrollEdgeAppearance = defaultAppearance
        }
    }
    
    
    
    //每个分区section有多少行row
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    //用哪个cell；indexPath即对应上面的row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selectedCategory!.colorString)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)){
                cell.backgroundColor = color
                cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added yet."
        }
        

        
        return cell
    }
    
    //选择cell会发生的事情
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write{
                    //update data
                    item.done = !item.done
                }
            }catch{
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        
        //选择后背景色会消失
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default)
            { (action) in
                
                if let currentCategory = self.selectedCategory{
                    do{
                        try self.realm.write{
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        }
                    }catch{
                        print("Error saving new items, \(error)")
                    }
                }
                           
                //重新渲染tableView
                self.tableView.reloadData()
            }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    //MARK: - Model Manipulation Methods
    
    func loadItems(){
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.todoItems?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(itemForDeletion)
                }
            }catch{
                print("Error saving done status, \(error)")
            }
        }
    }
    

    
}

//MARK: - Search Bar
extension TodoListViewController: UISearchBarDelegate{
    //当搜索按钮被点击时触发
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    //当searchBar里面文字变动时触发
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //当searchBar没有文字，即清空时回到初始界面
        if searchBar.text?.count == 0{
            loadItems()
            //光标和键盘消失
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
