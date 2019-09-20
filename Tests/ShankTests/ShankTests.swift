import XCTest
import Shank

final class DependencyTests: XCTestCase {
    
    private static let modules: [Module] = [
        WidgetModule(),
        SampleModule()
    ]
    
    @Inject private var widgetWorker: WidgetWorkerType
    @Inject private var someObject: SomeObjectType
    @Inject private var anotherObject: AnotherObjectType
    @Inject private var viewModelObject: ViewModelObjectType
    
    override class func setUp() {
        super.setUp()
        modules.register()
    }
}

// MARK: Subtypes

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

// MARK: - Test Cases

extension DependencyTests {
    
    func testResolver() {
        // Given
        let widgetResult = widgetWorker.fetch(id: 3)
        let someResult = someObject.testAbc()
        let anotherResult = anotherObject.testXyz()
        let viewModelResult = viewModelObject.testLmn()
        let viewModelNestedResult = viewModelObject.testLmnNested()
        
        // Then
        XCTAssertEqual(widgetResult, "|MediaRealmStore.3||MediaNetworkRemote.3|")
        XCTAssertEqual(someResult, "SomeObject.testAbc")
        XCTAssertEqual(anotherResult, "AnotherObject.testXyz|SomeObject.testAbc")
        XCTAssertEqual(viewModelResult, "SomeViewModel.testLmn|SomeObject.testAbc")
        XCTAssertEqual(viewModelNestedResult, "SomeViewModel.testLmnNested|AnotherObject.testXyz|SomeObject.testAbc")
    }
}

// MARK: - Test Data

protocol SomeObjectType {
    func testAbc() -> String
}

struct SomeObject: SomeObjectType {
    func testAbc() -> String {
        "SomeObject.testAbc"
    }
}

protocol AnotherObjectType {
    func testXyz() -> String
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

protocol ViewModelObjectType {
    func testLmn() -> String
    func testLmnNested() -> String
}

struct SomeViewModel: ViewModelObjectType {
    @Inject private var someObject: SomeObjectType
    @Inject private var anotherObject: AnotherObjectType
    
    func testLmn() -> String {
        "SomeViewModel.testLmn|" + someObject.testAbc()
    }
    
    func testLmnNested() -> String {
        "SomeViewModel.testLmnNested|" + anotherObject.testXyz()
    }
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

struct WidgetWorker: WidgetWorkerType {
    @Inject
    private var store: WidgetStore
    
    @Inject
    private var remote: WidgetRemote
    
    func fetch(id: Int) -> String {
        store.fetch(id: id)
            + remote.fetch(id: id)
    }
}

struct WidgetNetworkRemote: WidgetRemote {
    @Inject
    private var httpService: HTTPServiceType
    
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

protocol HTTPServiceType {
    func get(url: String) -> String
    func post(url: String) -> String
}
