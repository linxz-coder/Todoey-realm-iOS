import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        //监控初始化中的错误
        do{
            _ = try Realm() //因为不需要用到这个变量，所以用_，let也可以省略
        } catch {
            print("Error initialising new realm, \(error)")
        }
        
        
        return true
    }
}

