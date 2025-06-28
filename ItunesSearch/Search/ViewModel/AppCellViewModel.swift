import Foundation

struct AppCellViewModel {
    private let app: AppResult
    
    init(app: AppResult) {
        self.app = app
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
        return String(format: "%.1f ⭐ \(formattedRatingCount)", rating)
    }
    
    var formattedRatingCount: String {
        if ratingCount >= 1000000 {
            return String(format: "%.1fM ratings", Double(ratingCount) / 1000000)
        } else if ratingCount >= 1000 {
            return String(format: "%.1fK ratings", Double(ratingCount) / 1000)
        } else if ratingCount > 0 {
            return "\(ratingCount) ratings"
        } else {
            return "No ratings"
        }
    }
    
    var iconURL: String {
        return app.artworkUrl100
    }
}
