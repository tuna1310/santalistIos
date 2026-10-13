import XCTest
@testable import SantaList

final class GiftStatusTests: XCTestCase {
    func testNextCycle() {
        XCTAssertEqual(GiftStatus.idea.next(), .ordered)
        XCTAssertEqual(GiftStatus.ordered.next(), .received)
        XCTAssertEqual(GiftStatus.received.next(), .wrapped)
        XCTAssertEqual(GiftStatus.wrapped.next(), .idea)
    }

    func testFullCycleReturnsToStart() {
        var status = GiftStatus.idea
        status = status.next()
        status = status.next()
        status = status.next()
        status = status.next()
        XCTAssertEqual(status, .idea)
    }

    func testIsCompleted() {
        XCTAssertFalse(GiftStatus.idea.isCompleted)
        XCTAssertFalse(GiftStatus.ordered.isCompleted)
        XCTAssertTrue(GiftStatus.received.isCompleted)
        XCTAssertTrue(GiftStatus.wrapped.isCompleted)
    }

    func testIsCountedAsSpent() {
        XCTAssertFalse(GiftStatus.idea.isCountedAsSpent)
        XCTAssertTrue(GiftStatus.ordered.isCountedAsSpent)
        XCTAssertTrue(GiftStatus.received.isCountedAsSpent)
        XCTAssertTrue(GiftStatus.wrapped.isCountedAsSpent)
    }

    func testTitles() {
        XCTAssertEqual(GiftStatus.idea.title, "Idea")
        XCTAssertEqual(GiftStatus.ordered.title, "Ordered")
        XCTAssertEqual(GiftStatus.received.title, "Received")
        XCTAssertEqual(GiftStatus.wrapped.title, "Wrapped")
    }
}
