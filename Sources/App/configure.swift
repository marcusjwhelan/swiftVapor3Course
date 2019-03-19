import FluentSQLite
import Vapor
import Leaf
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentSQLiteProvider())

    // add leaf provider
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    // add auth service
    try services.register(AuthenticationProvider())


    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database.. in memory
    // let sqlite = try SQLiteDatabase(storage: .memory)
    // configure SQLIte not for in mem
    let directoryConfig = DirectoryConfig.detect() // access to this directory?
    services.register(directoryConfig)
    let sqlite = try SQLiteDatabase(storage: .file(path: "\(directoryConfig.workDir)MiniPost.db"))

    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Post.self, database: .sqlite)
    migrations.add(model: User.self, database: .sqlite)
    migrations.add(model: Token.self, database: .sqlite)
    services.register(migrations)
    User.PublicUser.defaultDatabase = .sqlite
}
