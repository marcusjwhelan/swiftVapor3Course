import Vapor
import Foundation
import FluentSQLite
import Authentication

final class User: Content {
    var id: Int?
    var username: String
    var password: String

    init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    final class PublicUser: Content {
        var id: Int?
        var username: String

        init(username: String) {
            self.username = username
        }

        init(user: User) {
            if let id: Int = user.id {
                self.id = id
            }
            self.username = user.username
        }
    }
}

extension User {
    // get children of User which
    // the post are teh children
    var posts: Children<User, Post> {
        return children(\.authorID)
    }
}

// make public user is like regular user
// don't need to include migration
extension User.PublicUser: SQLiteModel {
    public static let entity: String = User.entity
}
extension User.PublicUser: Parameter {}

extension User: SQLiteModel {}
extension User: Parameter {}
extension User: Migration {}

// for login
extension  User: BasicAuthenticatable {
    public static let usernameKey: UsernameKey = \User.username
    public static let passwordKey: PasswordKey = \User.password
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}