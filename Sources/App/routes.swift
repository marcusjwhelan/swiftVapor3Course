import Routing
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let postController = PostController()
    try router.register(collection: postController)

    let userController = UserController()
    try router.register(collection: userController)
}

/* used to be in routes(_ router: Router) throws {
// Basic "It works" example
    router.get { req in
        return "It works!"
    }

    // Basic "Hello, world!" example
    router.get("hello") { req -> Future<View> in
        return try req.view().render("hello", ["name": "Leaf"])
    }

    // forms
    router.get("posts/new") { req -> Future<View> in
        return try req.view().render("new", ["name": "Leaf"])
    }
    // request coming in from form
    router.post("posts") { req -> Future<Post> in

        let post = try req.content.decode(Post.self) // future return type
        return post
    }

    router.get("posts") { req -> Future<View> in
        struct Context: Codable {
            var posts: [String]
        }
        let context = Context(posts: ["Welcom", "micro", "test"])
        return try req.view().render("posts", context)
    }

    /*
        - /posts GET will show all posts
        - /posts POST will create a new post
        - /posts/:id GET will show post with id
        - /posts PATCH will update post
    */
    /*router.group("posts") { (posts) in
        posts.get("/") { req -> Response in
            // content protocol
            struct Context: Content {
                var post: String
                var from: String
            }

            let response = Response(using: req)
            // encoding method throws.
            try response.content.encode(Context(post: "Hello World", from: "Johann"))

            return response
        }
    }
*/

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
*/
