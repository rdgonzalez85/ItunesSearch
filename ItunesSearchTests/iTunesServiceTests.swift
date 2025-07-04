import XCTest
@testable import ItunesSearch

final class iTunesServiceTests: XCTestCase {

    func testGivenSessionWithExpectedApps_WhenSUTSearchApps_ThenCorrectAppsAreReturned() async throws {
        // Given
        let expectedApps = [AppResult.mock(), AppResult.mock()]
        let searchResponseEncoded = try SearchResponse(resultCount: 1, results: expectedApps).encode()
        
        func dataHandler(url: URL) async throws -> (Data, URLResponse) {
            return (searchResponseEncoded, URLResponse(url:url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil))
        }
        
        let session = MockURLSession()
        session.dataHandler = dataHandler
        let sut = iTunesService(session: session)
        
        // When
        let apps = try await sut.searchApps(query: "query")
        
        // Then
        XCTAssertEqual(apps, expectedApps)
    }

    func test_WhenSUTSearchAppsWithEmptyQuery_ThenErrorIsThrown() async throws {
        // Given
        let session = MockURLSession()
        let sut = iTunesService(session: session)
        
        // When
        do {
            _ = try await sut.searchApps(query: "")
            XCTFail("searchApps should throw")
        } catch let error {
            // Then
            let error = try XCTUnwrap(error as? NetworkError)
            XCTAssertEqual(error, NetworkError.invalidURL)
        }
    }
}

extension SearchResponse {
    static let mock = SearchResponse(resultCount: 1, results: [.mock(), .mock()])
    func encode() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
