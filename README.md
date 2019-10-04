# Shank

A Swift micro-library that provides lightweight dependency injection.

Read more here: https://basememara.com/swift-dependency-injection-via-property-wrapper/

Inject dependencies via property wrappers:
```swift
class ViewController: UIViewController {
    
    @Inject private var widgetModule: WidgetModuleType
    @Inject private var sampleModule: SampleModuleType
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        widgetModule.test()
        sampleModule.test()
    }
}
```
Register modules early in your app:
```swift
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let dependencies = Dependencies {
        Module { WidgetModule() as WidgetModuleType }
        Module { SampleModule() as SampleModuleType }
    }
    
    override init() {
        super.init()
        dependencies.build()
    }
}
```
If you forget to `build` the dependency container, it will result in a run-time exception. 
Since there is no type-safety to guard against this, it is recommended to 
limit the dependency container to hold "modules" only:
```swift
struct WidgetModule: WidgetModuleType {
    
    func component() -> WidgetWorkerType {
        WidgetWorker(
            store: component(),
            remote: component()
        )
    }
    
    func component() -> WidgetRemote {
        WidgetNetworkRemote(httpService: component())
    }
    
    func component() -> WidgetStore {
        WidgetRealmStore()
    }
    
    func component() -> HTTPServiceType {
        HTTPService()
    }
    
    func test() -> String {
        "WidgetModule.test()"
    }
}

struct SampleModule: SampleModuleType {
    
    func component() -> SomeObjectType {
        SomeObject()
    }
    
    func component() -> AnotherObjectType {
        AnotherObject(someObject: component())
    }
    
    func component() -> ViewModelObjectType {
        SomeViewModel(
            someObject: component(),
            anotherObject: component()
        )
    }
    
    func component() -> ViewControllerObjectType {
        SomeViewController()
    }
    
    func test() -> String {
        "SampleModule.test()"
    }
}

// MARK: API

protocol WidgetModuleType {
    func component() -> WidgetWorkerType
    func component() -> WidgetRemote
    func component() -> WidgetStore
    func component() -> HTTPServiceType
    func test() -> String
}

protocol SampleModuleType {
    func component() -> SomeObjectType
    func component() -> AnotherObjectType
    func component() -> ViewModelObjectType
    func component() -> ViewControllerObjectType
    func test() -> String
}
```
Then resolve individual components lazily:
```swift
class ViewController: UIViewController {
    
    @Inject private var widgetModule: WidgetModuleType
    @Inject private var sampleModule: SampleModuleType
    
    private lazy var widgetWorker: WidgetWorkerType = widgetModule.component()
    private lazy var someObject: SomeObjectType = sampleModule.component()
    private lazy var anotherObject: AnotherObjectType = sampleModule.component()
    private lazy var viewModelObject: ViewModelObjectType = sampleModule.component()
    private lazy var viewControllerObject: ViewControllerObjectType = sampleModule.component()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        widgetModule.test() //"WidgetModule.test()"
        sampleModule.test() //"SampleModule.test()"
        widgetWorker.fetch(id: 3) //"|MediaRealmStore.3||MediaNetworkRemote.3|"
        someObject.testAbc() //"SomeObject.testAbc"
        anotherObject.testXyz() //"AnotherObject.testXyz|SomeObject.testAbc"
        viewModelObject.testLmn() //"SomeViewModel.testLmn|SomeObject.testAbc"
        viewModelObject.testLmnNested() //"SomeViewModel.testLmnNested|AnotherObject.testXyz|SomeObject.testAbc"
        viewControllerObject.testRst() //"SomeViewController.testRst|SomeObject.testAbc"
        viewControllerObject.testRstNested() //"SomeViewController.testRstNested|AnotherObject.testXyz|SomeObject.testAbc"
    }
}

// MARK: - Subtypes

extension DependencyTests {

struct WidgetModule: WidgetModuleType {
    
    func component() -> WidgetWorkerType {
        WidgetWorker(
            store: component(),
            remote: component()
        )
    }
    
    func component() -> WidgetRemote {
        WidgetNetworkRemote(httpService: component())
    }
    
    func component() -> WidgetStore {
        WidgetRealmStore()
    }
    
    func component() -> HTTPServiceType {
        HTTPService()
    }
    
    func test() -> String {
        "WidgetModule.test()"
    }
}

struct SampleModule: SampleModuleType {
    
    func component() -> SomeObjectType {
        SomeObject()
    }
    
    func component() -> AnotherObjectType {
        AnotherObject(someObject: component())
    }
    
    func component() -> ViewModelObjectType {
        SomeViewModel(
            someObject: component(),
            anotherObject: component()
        )
    }
    
    func component() -> ViewControllerObjectType {
        SomeViewController()
    }
    
    func test() -> String {
        "SampleModule.test()"
    }
}

struct SomeObject: SomeObjectType {
    func testAbc() -> String {
        "SomeObject.testAbc"
    }
}

struct AnotherObject: AnotherObjectType {
    private let someObject: SomeObjectType
    
    init(someObject: SomeObjectType) {
        self.someObject = someObject
    }
    
    func testXyz() -> String {
        "AnotherObject.testXyz|" + someObject.testAbc()
    }
}

struct SomeViewModel: ViewModelObjectType {
    private let someObject: SomeObjectType
    private let anotherObject: AnotherObjectType
    
    init(someObject: SomeObjectType, anotherObject: AnotherObjectType) {
        self.someObject = someObject
        self.anotherObject = anotherObject
    }
    
    func testLmn() -> String {
        "SomeViewModel.testLmn|" + someObject.testAbc()
    }
    
    func testLmnNested() -> String {
        "SomeViewModel.testLmnNested|" + anotherObject.testXyz()
    }
}

class SomeViewController: ViewControllerObjectType {
    @Inject private var module: SampleModuleType
    
    private lazy var someObject: SomeObjectType = module.component()
    private lazy var anotherObject: AnotherObjectType = module.component()
    
    func testRst() -> String {
        "SomeViewController.testRst|" + someObject.testAbc()
    }
    
    func testRstNested() -> String {
        "SomeViewController.testRstNested|" + anotherObject.testXyz()
    }
}

struct WidgetWorker: WidgetWorkerType {
    private let store: WidgetStore
    private let remote: WidgetRemote
    
    init(store: WidgetStore, remote: WidgetRemote) {
        self.store = store
        self.remote = remote
    }
    
    func fetch(id: Int) -> String {
        store.fetch(id: id)
            + remote.fetch(id: id)
    }
}

struct WidgetNetworkRemote: WidgetRemote {
    private let httpService: HTTPServiceType
    
    init(httpService: HTTPServiceType) {
        self.httpService = httpService
    }
    
    func fetch(id: Int) -> String {
        "|MediaNetworkRemote.\(id)|"
    }
}

struct WidgetRealmStore: WidgetStore {
    
    func fetch(id: Int) -> String {
        "|MediaRealmStore.\(id)|"
    }
    
    func createOrUpdate(_ request: String) -> String {
        "MediaRealmStore.createOrUpdate\(request)"
    }
}

struct HTTPService: HTTPServiceType {
    
    func get(url: String) -> String {
        "HTTPService.get"
    }
    
    func post(url: String) -> String {
        "HTTPService.post"
    }
}

// MARK: API

protocol WidgetModuleType {
    func component() -> WidgetWorkerType
    func component() -> WidgetRemote
    func component() -> WidgetStore
    func component() -> HTTPServiceType
    func test() -> String
}

protocol SampleModuleType {
    func component() -> SomeObjectType
    func component() -> AnotherObjectType
    func component() -> ViewModelObjectType
    func component() -> ViewControllerObjectType
    func test() -> String
}

protocol SomeObjectType {
    func testAbc() -> String
}

protocol AnotherObjectType {
    func testXyz() -> String
}

protocol ViewModelObjectType {
    func testLmn() -> String
    func testLmnNested() -> String
}

protocol ViewControllerObjectType {
    func testRst() -> String
    func testRstNested() -> String
}

protocol WidgetStore {
    func fetch(id: Int) -> String
    func createOrUpdate(_ request: String) -> String
}

protocol WidgetRemote {
    func fetch(id: Int) -> String
}

protocol WidgetWorkerType {
    func fetch(id: Int) -> String
}

protocol HTTPServiceType {
    func get(url: String) -> String
    func post(url: String) -> String
}
```
This way, only your "modules" are not type-safe, which is acceptable since
an exception with a missing module should happen early on and hopefully
obvious enough in development.

However, the individual components are type-safe and have greater flexiblity to include
parameters while resolving the component. The components should have their dependencies
injected through the constructor, which is the best form of dependency injection.
The modules get the property wrappers support and can even inject modules within modules.
