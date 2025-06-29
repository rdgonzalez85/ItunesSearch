import Foundation
import UIKit

protocol ImageLoaderProtocol {
    func loadImage(urlString: String) async throws -> UIImage?
}

struct ImageLoader: ImageLoaderProtocol {
    func loadImage(urlString: String) async throws -> UIImage? {
        guard let url = URL(string: urlString) else { return nil}
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard !Task.isCancelled else { return nil }
        
        return UIImage(data: data)
    }
}
