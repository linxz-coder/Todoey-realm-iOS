import Foundation
import RealmSwift

class CategoryTitle: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var colorString: String = ""
    
    //后向关系
    let items = List<Item>()
}
