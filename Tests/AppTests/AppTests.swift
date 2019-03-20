@testable import App
import Dispatch
import XCTest


final class AppTests: XCTestCase {
    func testNothing() throws {
        // Add your tests here
        XCTAssert(true)
    }

    func testPublicUserInit() throws {
        let user = User(username: "marcus", password: "admin")
        let publicUser = User.PublicUser(user: user)
        XCTAssertEqual(user.username, publicUser.username, "PublicUser Init keeps user value")

    }

    static let allTests = [
        ("testNothing", testNothing),
        ("testPublicUserInit", testPublicUserInit)
    ]
}
