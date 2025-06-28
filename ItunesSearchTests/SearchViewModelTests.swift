import XCTest
@testable import ItunesSearch

final class SearchViewModelTests: XCTestCase {

    @MainActor
    func testGivenServiceThatReturnsApps_WhenSearchViewModelSearchApps_CorrectAppsAreReturned() async {
        // Given
        let expectedApps = [AppResult.mock(), AppResult.mock()]
        let service = MockiTunesService()
        service.defaultSuccessResults = expectedApps
        service.defaultError = NetworkError.invalidURL
        let viewModel = SearchViewModel(iTunesService: service)
        
        // When
        await viewModel.searchApps(query: "query")
        
        // Then
        XCTAssertNotNil(viewModel.apps)
        XCTAssertEqual(viewModel.apps.count, expectedApps.count)
        
        for (index, value) in viewModel.apps.enumerated() {
            XCTAssertTrue(value.isEqualTo(expectedApps[index]))
        }
    }
    
    @MainActor
    func testGivenServiceThatReturnsAnError_WhenSearchViewModelSearchApps_ErrorIsReturned() async {
        // Given
        let service = MockiTunesService()
        service.defaultError = NetworkError.invalidURL
        let viewModel = SearchViewModel(iTunesService: service)
        
        // When
        await viewModel.searchApps(query: "query")
        
        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        
    }
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString("this is an error", comment: "My error")
    }
}
