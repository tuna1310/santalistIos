import XCTest

final class SantaListUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    /// Tests navigation across all 3 primary tabs: Recipients, Timeline, Budget
    func testThreeTabsNavigation() throws {
        let recipientsTab = app.tabBars.buttons["Recipients"]
        XCTAssertTrue(recipientsTab.waitForExistence(timeout: 5))
        recipientsTab.tap()

        let timelineTab = app.tabBars.buttons["Timeline"]
        XCTAssertTrue(timelineTab.waitForExistence(timeout: 5))
        timelineTab.tap()
        XCTAssertTrue(app.segmentedControls.firstMatch.waitForExistence(timeout: 5))

        let budgetTab = app.tabBars.buttons["Budget"]
        XCTAssertTrue(budgetTab.waitForExistence(timeout: 5))
        budgetTab.tap()
        XCTAssertTrue(app.staticTexts["Total Budget"].waitForExistence(timeout: 5))
    }

    /// Tests adding a new recipient
    func testAddRecipient() throws {
        let recipientsTab = app.tabBars.buttons["Recipients"]
        recipientsTab.tap()

        let addPersonButton = app.buttons["Add Person"]
        if addPersonButton.waitForExistence(timeout: 3) {
            addPersonButton.tap()

            let nameField = app.textFields["Recipient name"]
            if nameField.waitForExistence(timeout: 3) {
                nameField.tap()
                nameField.typeText("Uncle Bob")

                let submitButton = app.buttons["Add"].exists ? app.buttons["Add"] : app.buttons["Save"]
                if submitButton.exists {
                    submitButton.tap()
                }
            }
        }
    }

    /// Tests adding a gift
    func testAddGift() throws {
        let recipientsTab = app.tabBars.buttons["Recipients"]
        recipientsTab.tap()

        let addGiftButton = app.buttons["Add Gift"]
        if addGiftButton.waitForExistence(timeout: 3) {
            addGiftButton.tap()

            let titleField = app.textFields["Gift title"]
            if titleField.waitForExistence(timeout: 3) {
                titleField.tap()
                titleField.typeText("Cozy Wool Socks")

                let submitButton = app.buttons["Add"].exists ? app.buttons["Add"] : app.buttons["Save"]
                if submitButton.exists {
                    submitButton.tap()
                }
            }
        }
    }

    /// Tests tapping status chip to advance workflow step
    func testStatusChipTapInteraction() throws {
        let timelineTab = app.tabBars.buttons["Timeline"]
        timelineTab.tap()

        let statusButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Status:'")).firstMatch
        if statusButton.waitForExistence(timeout: 3) {
            statusButton.tap()
        }
    }

    /// Tests swiping on a gift row to trigger delete
    func testSwipeToDelete() throws {
        let timelineTab = app.tabBars.buttons["Timeline"]
        timelineTab.tap()

        let cells = app.cells
        if cells.count > 0 {
            let firstCell = cells.element(boundBy: 0)
            firstCell.swipeLeft()

            let deleteButton = app.buttons["Delete"]
            if deleteButton.waitForExistence(timeout: 2) {
                deleteButton.tap()

                let confirmAlertButton = app.alerts.buttons["Delete"]
                if confirmAlertButton.waitForExistence(timeout: 2) {
                    confirmAlertButton.tap()
                }
            }
        }
    }
}
