import Foundation
@testable import ItunesSearch

class MockiTunesService: iTunesServiceProtocol {

    // MARK: - Properties to track calls

    /// An array to store the search `query` strings that have been made.
    /// This is useful for asserting that specific queries were executed.
    var searchQueries: [String] = []

    /// A closure that will be executed when `searchApps(query:)` is called.
    /// This allows you to provide a custom, dynamic response for each call during a test.
    /// The closure takes the `String` query and should return an array of `AppResult` or throw an `Error`.
    /// `(String) async throws -> [AppResult]`
    var searchAppsHandler: ((String) async throws -> [AppResult])?

    // MARK: - Stored results for predefined responses

    /// A dictionary to store predefined successful results (`[AppResult]`) for specific search queries.
    /// Key: Search query string, Value: Array of `AppResult`.
    var predefinedSuccessResults: [String: [AppResult]] = [:]

    /// A dictionary to store predefined errors (`Error`) for specific search queries.
    /// Key: Search query string, Value: `Error`.
    var predefinedErrors: [String: Error] = [:]

    /// A default successful result to return if no specific query-based result is set.
    var defaultSuccessResults: [AppResult]?

    /// A default error to throw if no specific query-based error is set.
    var defaultError: Error?

    // MARK: - iTunesServiceProtocol Conformance

    func searchApps(query: String) async throws -> [AppResult] {
        // Record the search query for later assertion
        searchQueries.append(query)

        // Try to use the custom handler first, if provided
        if let handler = searchAppsHandler {
            do {
                let result = try await handler(query)
                return result
            } catch {
                // If the handler throws, re-throw its error
                throw error
            }
        }

        // If no handler, or handler didn't handle the query, use predefined results
        if let results = predefinedSuccessResults[query] {
            return results
        } else if let error = predefinedErrors[query] {
            throw error
        } else if let defaultResults = defaultSuccessResults {
            // Fallback to default success if no specific query result
            return defaultResults
        } else if let error = defaultError {
            // Fallback to default error if no specific query error
            throw error
        } else {
            // Default error if no specific mock response is set up
            throw NSError(domain: "MockiTunesServiceError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No mock response set for query: '\(query)'"])
        }
    }

    // MARK: - Helper Methods for Mock Configuration

    /// Sets a predefined successful array of `AppResult` for a given search query.
    /// - Parameters:
    ///   - results: The array of `AppResult` to return on success.
    ///   - query: The specific search query for which these results should be provided.
    func setSuccess(results: [AppResult], forQuery query: String) {
        predefinedSuccessResults[query] = results
    }

    /// Sets a predefined error for a given search query.
    /// - Parameters:
    ///   - error: The `Error` to throw on failure.
    ///   - query: The specific search query for which this error should be thrown.
    func setError(error: Error, forQuery query: String) {
        predefinedErrors[query] = error
    }

    /// Sets a default successful array of `AppResult` to be returned for any query
    /// if no specific `setSuccess(results:forQuery:)` or `searchAppsHandler` is matched.
    func setDefaultSuccess(results: [AppResult]) {
        defaultSuccessResults = results
    }

    /// Sets a default `Error` to be thrown for any query
    /// if no specific `setError(error:forQuery:)` or `searchAppsHandler` is matched.
    func setDefaultError(error: Error) {
        defaultError = error
    }

    /// Resets all recorded queries and predefined results.
    func reset() {
        searchQueries = []
        searchAppsHandler = nil
        predefinedSuccessResults = [:]
        predefinedErrors = [:]
        defaultSuccessResults = nil
        defaultError = nil
    }
}
