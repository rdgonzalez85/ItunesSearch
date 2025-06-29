import Foundation
import Network

protocol NetworkReachabilityProtocol {
    var isConnected: Bool { get }
    func startMonitoring()
    func stopMonitoring()
}

protocol NWPathMonitorProtocol {
    var pathUpdateHandler: ((NWPath) -> Void)? { get set }
    func start(queue: DispatchQueue)
    func cancel()
}

extension NWPathMonitor: NWPathMonitorProtocol {}

class NetworkReachability: NetworkReachabilityProtocol {
    private var monitor: NWPathMonitorProtocol
    private let queue: DispatchQueue
    
    private(set) var isConnected: Bool = false
    
    
    init(
        monitor: NWPathMonitorProtocol = NWPathMonitor(),
        queue: DispatchQueue = DispatchQueue(label: "NetworkReachability")
    ) {
        self.monitor = monitor
        self.queue = queue
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let newConnectionStatus = path.status == .satisfied
            if self.isConnected != newConnectionStatus {
                self.isConnected = newConnectionStatus
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    deinit {
        stopMonitoring()
    }
}
