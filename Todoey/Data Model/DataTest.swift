import Foundation
import RealmSwift

class Data: Object{
    @objc dynamic var name: String = "" //dynamic是objective-c的语法，相当于\@state
    @objc dynamic var age: Int = 0
    
}
