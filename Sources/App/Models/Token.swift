import Vapor
import Foundation
import Authentication
import FluentMySQL
import Random
import Crypto

final class Token: Content {
    var id: Int?
    var token: String
    var userID: User.ID

    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
    // if given a user want to give a new token given that user
    init(_ user: User) throws {
        let token = try URandom().generateData(count: 16).base64EncodedString()
        self.token = token
        let userId = try user.requireID()
        self.userID = userId
    }
}

extension Token: MySQLModel {}
extension Token: Migration {}

// add relationship to user
extension Token {
    var user: Parent<Token, User> {
        return parent(\.userID)
    }
}
// ask us to relate token to our user
extension Token: Authentication.Token {
    public static let userIDKey: UserIDKey = \Token.userID
    typealias UserType = User
}
extension Token: BearerAuthenticatable {
    public static let tokenKey: TokenKey = \Token.token
}