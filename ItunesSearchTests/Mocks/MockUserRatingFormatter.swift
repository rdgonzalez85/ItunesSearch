import Foundation
@testable import ItunesSearch

struct MockUserRatingFormatter: UserRatingFormatterProtocol {
    func format(_ rating: Int) -> String {
        return String(rating)
    }
}
