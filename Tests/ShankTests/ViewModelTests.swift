import XCTest
import Shank

final class SimpleTests: XCTestCase {

    @Inject
    private var viewModel: ViewModelType

    @Inject
    private var anotherViewModel: ViewModelType
    
    override class func setUp() {
        super.setUp()
        
        Resolver.register {
            MyViewModel() as ViewModelType
        }
    }
}

extension SimpleTests {
    
    func testResolve() {
        //XCTAssertEqual(viewModel.load(), 5)
    }
}

protocol ViewModelType {
    func load() -> Int
}

struct MyViewModel: ViewModelType {
    func load() -> Int { 5 }
}

struct AnotherViewModel: ViewModelType {
    func load() -> Int { 20 }
}
