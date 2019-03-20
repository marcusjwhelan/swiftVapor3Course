import Vapor
import Foundation
import FluentMySQL


final class Post: Content {
    var content: String
    var authorID: User.ID
    var id: Int? // primary key

    init(content: String, authorID: User.ID) {
        self.content = content
        self.authorID = authorID
    }
}

struct PostData: Content {
    var content: String
}

extension Post {
    // look for parernt look for author id on post table
    // and give us back a user
    var author: Parent<Post, User> {
        return parent(\.authorID)
    }
}

extension Post: MySQLModel {}
extension Post: Migration {}
extension Post: Parameter {} // needed for get /posts/:id