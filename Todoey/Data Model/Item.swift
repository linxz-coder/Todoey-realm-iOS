import Foundation
import RealmSwift

class Item: Object{
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    //前向关系
    var parentCategory = LinkingObjects(fromType: CategoryTitle.self, property: "items")
}
