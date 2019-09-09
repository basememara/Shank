import XCTest
import Shank

final class FactoryTests: XCTestCase {
    
    @Inject
    var service1: MyServiceType

    @Inject
    var service2: MyServiceType
    
    override func setUp() {
        super.setUp()
        MyService.counter = 0
    }
}

extension FactoryTests {
    
    func testResolve() {
        // Given
        _ = service1.counter
        _ = service2.counter
        
        // Then
        XCTAssertEqual(MyService.counter, 2)
    }
}

protocol MyServiceType {
    var counter: Int { get }
    init()
}

struct MyService: MyServiceType {
    static var counter = 0
    var counter: Int { MyService.counter }
    init() { MyService.counter += 1 }
}
