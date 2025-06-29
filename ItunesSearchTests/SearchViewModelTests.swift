import XCTest
@testable import ItunesSearch

final class SearchViewModelTests: XCTestCase {

    @MainActor
    func testGivenServiceThatReturnsApps_WhenSUTSearchApps_CorrectAppsAreReturned() async {
        // Given
        let expectedApps = [AppResult.mock(), AppResult.mock()]
        let service = MockiTunesService()
        service.defaultSuccessResults = expectedApps
        service.defaultError = NetworkError.invalidURL
        let sut = self.makeSUT(iTunesService: service)
        
        // When
        await sut.searchApps(query: "query")
        
        // Then
        XCTAssertNotNil(sut.apps)
        XCTAssertEqual(sut.apps.count, expectedApps.count)
        
        for (index, value) in sut.apps.enumerated() {
            XCTAssertTrue(value.isEqualTo(expectedApps[index]))
        }
    }
    
    @MainActor
    func testGivenServiceThatReturnsAnError_WhenSUTSearchApps_ErrorIsReturned() async {
        // Given
        let service = MockiTunesService()
        service.defaultError = NetworkError.invalidURL
        let sut = self.makeSUT(iTunesService: service)
        
        // When
        await sut.searchApps(query: "query")
        
        // Then
        XCTAssertNotNil(sut.errorMessage)
    }
    
    private func makeSUT(
        iTunesService: iTunesServiceProtocol = MockiTunesService(),
        coreDataManager: CoreDataManagerProtocol = MockCoreDataManager(),
        networkReachability: NetworkReachabilityProtocol = MockNetworkReachability()
    ) -> SearchViewModel {
        return SearchViewModel(
            iTunesService: iTunesService,
            coreDataManager: coreDataManager,
            networkReachability: networkReachability
        )
    }
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString("this is an error", comment: "My error")
    }
}
