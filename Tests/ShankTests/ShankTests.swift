import XCTest
import Shank

final class GraphTests: XCTestCase {

    @Inject
    private var mediaWorker: MediaWorkerType
}

extension GraphTests {
    
    func testResolve() {
        // Given
        let result = mediaWorker.fetch(id: 3)
        
        // Then
        XCTAssertEqual(result, "")
    }
}

extension Resolver: ResolverRegistering {
    
    public static func registerAllServices() {
        register { MediaWorker(store: resolve(), remote: optional()) as MediaWorkerType }
        register { MediaNetworkRemote(httpService: resolve()) as MediaRemote }
        register { MediaRealmStore() as MediaStore }
        register { HTTPService() as HTTPServiceType }
        
        register { MyService() as MyServiceType }
    }
}

// MARK: - API

protocol MediaStore {
    func fetch(id: Int) -> String
    func createOrUpdate(_ request: String) -> String
}

protocol MediaRemote {
    func fetch(id: Int) -> String
}

protocol MediaWorkerType {
    func fetch(id: Int) -> String
}

struct MediaWorker: MediaWorkerType {
    private let store: MediaStore
    private let remote: MediaRemote?
    
    init(store: MediaStore, remote: MediaRemote?) {
        self.store = store
        self.remote = remote
    }
    
    func fetch(id: Int) -> String {
        store.fetch(id: id)
            + (remote?.fetch(id: id) ?? "")
    }
}

struct MediaNetworkRemote: MediaRemote {
    private let httpService: HTTPServiceType
    
    init(httpService: HTTPServiceType) {
        self.httpService = httpService
    }
    
    func fetch(id: Int) -> String {
        "|MediaNetworkRemote.\(id)|"
    }
}

struct MediaRealmStore: MediaStore {
    
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
