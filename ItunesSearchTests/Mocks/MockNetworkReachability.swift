import Foundation
@testable import ItunesSearch

class MockNetworkReachability: NetworkReachabilityProtocol {

    // MARK: - Properties to track calls and state

    /// A mutable property to control the `isConnected` state for testing.
    /// You can set this directly in your tests to simulate network connectivity.
    var isConnected: Bool

    /// A flag to track if `startMonitoring()` has been called.
    var startMonitoringCalled: Bool = false

    /// A flag to track if `stopMonitoring()` has been called.
    var stopMonitoringCalled: Bool = false

    // MARK: - Initialization

    /// Initializes the mock with a default connectivity state.
    /// - Parameter isConnected: The initial connectivity state for the mock.
    init(isConnected: Bool = true) {
        self.isConnected = isConnected
    }

    // MARK: - NetworkReachabilityProtocol Conformance

    func startMonitoring() {
        // Record that the method was called
        startMonitoringCalled = true
        print("MockNetworkReachability: startMonitoring() called.")
        // In a real scenario, this might trigger a change in `isConnected`
        // but for a mock, we primarily track the call.
    }

    func stopMonitoring() {
        // Record that the method was called
        stopMonitoringCalled = true
        print("MockNetworkReachability: stopMonitoring() called.")
        // In a real scenario, this might disable network checks.
    }

    // MARK: - Helper Methods for Mock Configuration

    /// Resets all tracking flags to their initial state.
    func reset() {
        startMonitoringCalled = false
        stopMonitoringCalled = false
        // Note: isConnected is usually set per test, so we don't reset it here
        // unless a specific default behavior is desired.
    }

    /// Sets the `isConnected` property. Useful for changing connectivity mid-test.
    /// - Parameter connected: The new connectivity state.
    func setConnected(_ connected: Bool) {
        self.isConnected = connected
    }
}
