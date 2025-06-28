import Foundation
@testable import ItunesSearch

class MockURLSession: URLSessionProtocol {

    // MARK: - Properties to track calls

    /// An array to store the URLs that have been requested.
    /// This is useful for asserting that specific URLs were called.
    var requestedURLs: [URL] = []

    /// A closure that will be executed when `data(from:)` is called.
    /// This allows you to provide a custom response for each call during a test.
    /// The closure takes the `URL` and should return a `Result` of `(Data, URLResponse)` or `Error`.
    /// `(URL) async throws -> (Data, URLResponse)`
    var dataHandler: ((URL) async throws -> (Data, URLResponse))?

    // MARK: - Stored results for predefined responses

    /// A dictionary to store predefined success results (Data, URLResponse) for specific URLs.
    /// Key: URL, Value: (Data, URLResponse)
    var predefinedResponses: [URL: (Data, URLResponse)] = [:]

    /// A dictionary to store predefined errors for specific URLs.
    /// Key: URL, Value: Error
    var predefinedErrors: [URL: Error] = [:]

    // MARK: - URLSessionProtocol Conformance

    func data(from url: URL) async throws -> (Data, URLResponse) {
        // Record the requested URL for later assertion
        requestedURLs.append(url)

        // Try to use the custom handler first, if provided
        if let handler = dataHandler {
            do {
                let result = try await handler(url)
                return result
            } catch {
                // If the handler throws, re-throw its error
                throw error
            }
        }

        // If no handler, or handler didn't handle the URL, use predefined results
        if let response = predefinedResponses[url] {
            return response
        } else if let error = predefinedErrors[url] {
            throw error
        } else {
            // Default error if no specific mock response is set up for the given URL
            throw URLError(.cannotFindHost, userInfo: [NSLocalizedDescriptionKey: "No mock response set for URL: \(url.absoluteString)"])
        }
    }

    // MARK: - Helper Methods for Mock Configuration

    /// Sets a predefined successful data and URLResponse for a given URL.
    /// - Parameters:
    ///   - data: The data to return.
    ///   - response: The URLResponse to return.
    ///   - url: The URL for which this response should be provided.
    func setSuccess(data: Data, response: URLResponse, for url: URL) {
        predefinedResponses[url] = (data, response)
    }

    /// Sets a predefined error for a given URL.
    /// - Parameters:
    ///   - error: The error to throw.
    ///   - url: The URL for which this error should be thrown.
    func setError(error: Error, for url: URL) {
        predefinedErrors[url] = error
    }

    /// Resets all recorded requests and predefined results.
    func reset() {
        requestedURLs = []
        predefinedResponses = [:]
        predefinedErrors = [:]
        dataHandler = nil
    }
}
