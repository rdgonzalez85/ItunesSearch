import XCTest
@testable import ItunesSearch

final class UserRatingFormatterTests: XCTestCase {
    func test_WhenSUTFormats_ThenReturnsTheCorrectValue() {
        let sut = UserRatingFormatter()
        
        var format = sut.format(1213310) // 1,213,310
        XCTAssertEqual(format, "1.2M ratings")
        
        format = sut.format(213310) // 213,310
        XCTAssertEqual(format, "213.3K ratings")
        
        format = sut.format(310)
        XCTAssertEqual(format, "310 ratings")
        
        format = sut.format(0)
        XCTAssertEqual(format, "No ratings")
    }
}
