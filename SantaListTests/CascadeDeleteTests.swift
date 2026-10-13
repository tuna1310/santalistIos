import XCTest
import SwiftData
@testable import SantaList

@MainActor
final class CascadeDeleteTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        let schema = Schema([Person.self, Gift.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        context = container.mainContext
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    func testCascadeDeleteRemovesAssociatedGifts() throws {
        let person = Person(name: "Thử Nghiệm", budget: 1_000_000)
        context.insert(person)

        let gift1 = Gift(title: "Quà 1", price: 200_000, person: person)
        let gift2 = Gift(title: "Quà 2", price: 300_000, person: person)
        context.insert(gift1)
        context.insert(gift2)
        person.gifts = [gift1, gift2]

        try context.save()

        // Kiểm tra ban đầu có 1 Person và 2 Gifts
        let initialPeople = try context.fetch(FetchDescriptor<Person>())
        XCTAssertEqual(initialPeople.count, 1)

        let initialGifts = try context.fetch(FetchDescriptor<Gift>())
        XCTAssertEqual(initialGifts.count, 2)

        // Thực hiện xóa Person
        context.delete(person)
        try context.save()

        // Xác nhận Person đã bị xóa
        let remainingPeople = try context.fetch(FetchDescriptor<Person>())
        XCTAssertEqual(remainingPeople.count, 0)

        // Xác nhận tất cả Gift liên quan đã tự động bị xóa cascade
        let remainingGifts = try context.fetch(FetchDescriptor<Gift>())
        XCTAssertEqual(remainingGifts.count, 0, "Tất cả các món quà phải tự động bị xóa cascade khi người nhận bị xóa")
    }
}
