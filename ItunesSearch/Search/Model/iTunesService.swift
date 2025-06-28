import Foundation

protocol iTunesServiceProtocol {
    func searchApps(query: String) async throws -> [AppResult]
}

class iTunesService: iTunesServiceProtocol {
    private let session: URLSessionProtocol
    private let baseURL = "https://itunes.apple.com/search"
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func searchApps(query: String) async throws -> [AppResult] {
        guard !query.isEmpty else { throw NetworkError.invalidURL }
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = queryItems(query: query)
                
        guard let url = components?.url else { throw NetworkError.invalidURL }
        
        let (data, _) = try await session.data(from: url)
        let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
        return searchResponse.results
    }
    
    func queryItems(query: String) -> [URLQueryItem] {
        [
            URLQueryItem(name: "media", value: "software"),
            URLQueryItem(name: "entity", value: "software"),
            URLQueryItem(name: "limit", value: "50"),
            URLQueryItem(name: "term", value: query)
        ]
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
}

protocol URLSessionProtocol {
    func data(from: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol { }
