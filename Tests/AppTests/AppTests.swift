@testable import App
import Dispatch
import XCTest
import Vapor

final class AppTests: XCTestCase {
    var application: Application!
    // config for each test so each test has a fresh copy
    override func setUp() {
        // uses app func that creates real app but now supplies it with testing env value
        // self.app = app(env: Environment.testing)
        let ap: Application = try! app(Environment.testing)
        self.application = ap
    }

    // tear down for each test
    override func tearDown() {
        self.application = nil
    }

    func testNothing() throws {
        // Add your tests here
        XCTAssert(true)
    }

    func testPublicUserInit() throws {
        let user = User(username: "marcus", password: "admin")
        let publicUser = User.PublicUser(user: user)
        XCTAssertEqual(user.username, publicUser.username, "PublicUser Init keeps user value")

    }

    func testUserController() throws {
        // 1. create a user
        let request = Request(using: self.application)
        let user = User(username: "Marcus", password: "admin")
        user.save(on: request)

        // 2. send request to index action
        let userController = UserController()
        let users: [User.PublicUser] = try userController.index(request).wait() // future users

        // 3. compare details about our user with the response
        let lastUser = users.last! // grab the last user in the array
        XCTAssertEqual(lastUser.username, user.username, "Create User Finished")
        XCTAssertNotEqual(users.count, 0)
    }

    static let allTests = [
        ("testNothing", testNothing),
        ("testPublicUserInit", testPublicUserInit),
        ("testUserController", testUserController)
    ]
}
//  NOT NEEDED SINCE THERE IS AN APP.SWIFT FILE IN APP WE CAN USE
/*
extension Application {
    // create an instance of our application for testing
    public static func setUp() throws -> Application {
        // code from app.swift also is main.swift in legacy or in `run`
        var config: Config = Config.default()
        var env: Environment = try Environment.detect() // switch from env. no env param incoming
        var services: Services = Services.default()
        try configure(&config, &env, &services)
        let app: Application = try Application(config: config, environment: env, services: services)
        try boot(app)
        return app
    }
}
*/
