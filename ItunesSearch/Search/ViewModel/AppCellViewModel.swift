import Foundation

protocol AppCellViewModelProtocol {
    var appName: String { get }
    var developerName: String { get }
    var category: String { get }
    var price: String { get }
    var rating: Double { get }
    var ratingCount: Int { get }
    var ratingText: String { get }
    var iconURL: String { get }
    var appResult: AppResult { get }
}

struct AppCellViewModel: AppCellViewModelProtocol {
    private let app: AppResult
    private let reviewFormatter: UserRatingFormatterProtocol
    
    init(app: AppResult,
         reviewFormatter: UserRatingFormatterProtocol = UserRatingFormatter()) {
        self.app = app
        self.reviewFormatter = reviewFormatter
    }
    
    var appName: String {
        return app.trackName
    }
    
    var developerName: String {
        return app.artistName
    }
    
    var category: String {
        return app.primaryGenreName
    }
    
    var price: String {
        return app.formattedPrice ?? "Free"
    }
    
    var rating: Double {
        return app.averageUserRating ?? 0.0
    }
    
    var ratingCount: Int {
        return app.userRatingCount ?? 0
    }
    
    var ratingText: String {
        return String(format: "%.1f ⭐ \(self.reviewFormatter.format(ratingCount))", rating)
    }
    
    var iconURL: String {
        return app.artworkUrl100
    }

    var appResult: AppResult {
        return app
    }
}

protocol UserRatingFormatterProtocol {
    func format(_ rating: Int) -> String
}

struct UserRatingFormatter: UserRatingFormatterProtocol {
    func format(_ rating: Int) -> String {
        if rating >= 1000000 {
            return String(format: "%.1fM ratings", Double(rating) / 1000000)
        } else if rating >= 1000 {
            return String(format: "%.1fK ratings", Double(rating) / 1000)
        } else if rating > 0 {
            return "\(rating) ratings"
        } else {
            return "No ratings"
        }
    }
}
