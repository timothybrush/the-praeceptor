import XCTest
import Network
@testable import Praeceptor

@MainActor
final class NetworkMonitorTests: XCTestCase {

    func testMonitorCanBeInstantiated() {
        let monitor = NetworkMonitor()
        XCTAssertNotNil(monitor)
    }

    func testIsConnectedHasDefaultValue() {
        let monitor = NetworkMonitor()
        // Default is true — the monitor optimistically assumes connected until a path update fires.
        XCTAssertTrue(monitor.isConnected)
    }
}
