import XCTest
import Shank

final class SingletonTests: XCTestCase {
    
    @Inject
    var service1: MyServiceType

    @Inject
    var service2: MyServiceType
    
    override func setUp() {
        super.setUp()
        MyService.counter = 0
    }
}

extension SingletonTests {
    
    func testResolve() {
        // Given
        var service1Counter = service1.counter
        let service2Counter = service2.counter
        
        // Then
        XCTAssertEqual(MyService.counter, 1)
    }
}
