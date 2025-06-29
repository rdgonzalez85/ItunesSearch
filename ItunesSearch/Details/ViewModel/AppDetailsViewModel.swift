import Foundation

protocol AppDetailsViewModelProtocol {
    var appName: String { get }
    var developerName: String { get }
    var category: String { get }
    var price: String { get }
    var rating: Double { get }
    var ratingCount: Int { get }
    var ratingText: String { get }
    var description: String { get }
    var iconURL: String { get }
    var screenshotURLs: [String] { get }
    var informationItems: [InformationItem] { get }
}


struct AppDetailsViewModel: AppDetailsViewModelProtocol {
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
        return String(format: "%.1f • \(self.reviewFormatter.format(ratingCount))", rating)
    }
    
    var description: String {
        return app.description.isEmpty ? "No description available." : app.description
    }
    
    var iconURL: String {
        return app.artworkUrl100
    }
    
    var screenshotURLs: [String] {
        return app.screenshotUrls
    }
    
    var informationItems: [InformationItem] {
        var items: [InformationItem] = []
        
        items.append(InformationItem(title: "Developer", value: app.artistName))
        items.append(InformationItem(title: "Category", value: app.primaryGenreName))
        
        if let price = app.formattedPrice, !price.isEmpty {
            items.append(InformationItem(title: "Price", value: price))
        }
        
        if let rating = app.averageUserRating, rating > 0 {
            items.append(InformationItem(title: "Rating", value: String(format: "%.1f out of 5", rating)))
        }
        
        if let ratingCount = app.userRatingCount, ratingCount > 0 {
            items.append(InformationItem(title: "Ratings", value: self.reviewFormatter.format(ratingCount)))
        }
        
        items.append(InformationItem(title: "Age Rating", value: app.trackContentRating))
        items.append(InformationItem(title: "Compatibility", value: "Requires iOS \(app.minimumOsVersion) or later"))

        return items
    }
}

struct InformationItem {
    let title: String
    let value: String
}
