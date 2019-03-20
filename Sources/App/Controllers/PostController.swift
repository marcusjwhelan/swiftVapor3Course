import Foundation
import Vapor
import Fluent
import Authentication

final class PostController: RouteCollection {
    func boot(router: Router) throws {
        // GET /posts
        // POST /posts

        let postRouter = router.grouped("posts")
        postRouter.get("/", use: index)
        postRouter.post("/", use: create)
        postRouter.get(Post.parameter, use: show) // used for "/:id"
        postRouter.delete(Post.parameter, use: destroy) // /:id
        postRouter.patch(Post.parameter, use: update) // update /:id
        // postRouter.get("/search", use: search)

        // posts/:id/author
        postRouter.get(Post.parameter, "author", use: showAuthor)

        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenGroup = postRouter.grouped(tokenAuthMiddleware)
        tokenGroup.post("/", use: authPostCreate)
    }

    func authPostCreate(_ req: Request) throws -> Future<Post> {
        // {content: "auth"} with token
        let user: User = try req.requireAuthenticated(User.self)
        return try req.content.decode(PostData.self)
                .flatMap(to: Post.self) { (post: PostData) in
                    return Post(content: post.content, authorID: user.id!).save(on: req)
                }
    }

    func index(_ req: Request) throws -> Future<[Post]> {
        // talk to db and return posts
        return Post.query(on: req)
                .all()
    }

    func create(_ req: Request) throws -> Future<Post> {
        return try req.content.decode(Post.self)
                .flatMap(to: Post.self) { (post: Post) in
                    let savedPost = post.save(on: req)
                    return savedPost
                }
    }

    // Get /posts/:id
    func show(_ req: Request) throws -> Future<Post> {
        return try req.parameters.next(Post.self)
    }

    // Delete /posts/:id
    func destroy(_ req: Request) throws -> Future<HTTPStatus> {
        // used to used flatMap wich made this return a Future<> hence the return type above
        // now Map so we can just return an HttpStatus
        return try req.parameters.next(Post.self)
                .map(to: HTTPStatus.self) { (post: Post) in
                    // should check that this user is only deleting his posts
                    let user = try req.requireAuthenticated(User.self)
                    if post.authorID == user.id! {
                        try post.delete(on: req).wait()
                        return HTTPStatus.noContent
                    } else {
                        return HTTPStatus.badRequest
                    }
                    // old return post.delete(on: req).transform(to: .noContent) // http sends back no content
                }
    }

    // Patch /posts/:id
    // also will have update to content
    // so decode as well
    func update(_ req: Request) throws -> Future<Post> {
        // read right to left
        // first decode the content
        // grab our parameter
        // and convert this inquery to a Post type
        return flatMap(to: Post.self, try req.parameters.next(Post.self), try req.content.decode(Post.self)) { (post: Post, updatedPost: Post) in
            // update the post
            post.content = updatedPost.content
            post.authorID = updatedPost.authorID
            return post.save(on: req)
        }
    }

    // posts/:id/author
    func showAuthor(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(Post.self)
                .flatMap(to: User.self) { (post: Post) in
                    // post now has author which returns that user
                    return post.author.get(on: req)
                }
    }

    // /posts/search?author=Marcus
    /*func search(_ req: Request) throws -> Future<[Post]> {
        // grab the query item = Marcus
        guard let searchItem = req.query[String.self, at: "author"] else {
            throw Abort(.badRequest)
        }
        // now query searching for matchign authors
        return Post.query(on: req)
                .filter(\.author == searchItem)
                .all()
    }*/
}
