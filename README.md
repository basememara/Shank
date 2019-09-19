# Shank

A Swift micro-library that provides lightweight dependency injection.

Create modules of dependencies:
```swift
struct WidgetModule: Module {
    
    func register() {
        make { WidgetWorker() as WidgetWorkerType }
        make { WidgetNetworkRemote() as WidgetRemote }
        make { WidgetRealmStore() as WidgetStore }
        make { HTTPService() as HTTPServiceType }
    }
}

struct SampleModule: Module {
    
    func register() {
        make { SomeObject() as SomeObjectType }
        make { AnotherObject(someObject: self.resolve()) as AnotherObjectType }
        make { SomeViewModel() as ViewModelObjectType }
    }
}
```
Register modules early in your app:
```swift
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let modules: [Module] = [
        WidgetModule(),
        SampleModule()
    ]
    
    override init() {
        super.init()
        modules.register()
    }
}
```
Inject dependencies for use:
```swift
class ViewController: UIViewController {
    
    @Inject private var widgetWorker: WidgetWorkerType
    @Inject private var someObject: SomeObjectType
    @Inject private var anotherObject: AnotherObjectType
    
    override func viewDidLoad() {
        super.viewDidLoad()
        widgetWorker.test()
    }
}
```
