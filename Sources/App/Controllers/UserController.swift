import Foundation
import Vapor
import Fluent
import Crypto
import Authentication

final class UserController: RouteCollection {
    func boot(router: Router) throws {
        // GET /users
        // POST /users

        let usersRouter = router.grouped("users")
        usersRouter.get("/", use: index)
        usersRouter.post("/", use: create)
        usersRouter.get(User.PublicUser.parameter, use: show) // used for "/:id"

        // users/:id/posts
        usersRouter.get(User.PublicUser.parameter, "posts", use: showPosts)

        // middleware
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let authGroup = usersRouter.grouped(basicAuthMiddleware)
        authGroup.post("login", use: loginHandler)

        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenGroup = usersRouter.grouped(tokenAuthMiddleware)
        tokenGroup.get("posts", use: handleUserPosts)
    }

    func handleUserPosts(_ req: Request) throws -> Future<[Post]> {
        let user: User = try req.requireAuthenticated(User.self)
        return try user.posts.query(on: req).all()
    }

    func loginHandler(_ req: Request) throws -> Future<Token> {
        let user: User = try req.requireAuthenticated(User.self)
        let token: Token = try Token(user)
        return token.save(on: req)
    }

    func index(_ req: Request) throws -> Future<[User.PublicUser]> {
        // talk to db and return users
        return User.PublicUser.query(on: req)
                .all()
    }

    func create(_ req: Request) throws -> Future<User.PublicUser> {
        /*
            {username: "Marcus", "password": "test"}
        */

        // need to encryp password
        return try req.content.decode(User.self)
                .flatMap(to: User.PublicUser.self) { (user: User) in
                    // user is now decoded
                    let hasher: BCryptDigest = try req.make(BCryptDigest.self)
                    if let hashedPass: String = try? hasher.hash(user.password) {
                        user.password = hashedPass
                    } else {
                        throw Abort(.internalServerError, reason: "Unable to hash password")
                    }
                    // save regular user
                    return user.save(on: req).map(to: User.PublicUser.self) { (savedUser: User) in
                        // create public user from user and return the public version
                        return User.PublicUser(user: savedUser)
                    }
                }
        /*return try req.content.decode(User.self)
                .flatMap(to: User.self) { (user: User) in
                    let savedUser = user.save(on: req)
                    return savedUser
                }*/
    }

    // Get /users/:id
    func show(_ req: Request) throws -> Future<User.PublicUser> {
        return try req.parameters.next(User.PublicUser.self)
    }

    func showPosts(_ req: Request) throws -> Future<[Post]> {
        // grap user. converty teh return value of the reques into collection of posts
        return try req.parameters.next(User.self)
                .flatMap(to: [Post].self) { (user: User) in
                    return try user.posts.query(on: req).all()
                }
    }
}
