import FluentMySQL
import Vapor
import Leaf
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    // try services.register(FluentSQLiteProvider())
    try services.register(FluentMySQLProvider())

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

    // create db based on env
    let db: MySQLDatabase

    if env.isRelease {
        let dbUrl = Environment.get("URL KEY IN HEROKU")
        // mysql prod
        let d = try MySQLDatabaseConfig(url: dbUrl!)!
        db = MySQLDatabase(config: d)
    } else {
        // mysql dev
        let d = MySQLDatabaseConfig(
                hostname: "127.0.0.1",
                port: 3306,
                username: "marcus",
                password: "marcus",
                database: "MiniPost"
        )
        db = MySQLDatabase(config: d)
    }

    services.register(db)
    // sqlite
    // Register the configured SQLite database to the database config.
    // var databases = DatabasesConfig()
    // databases.add(database: db, as: .mysql)
    // let sqlite = try SQLiteDatabase(storage: .file(path: "\(directoryConfig.workDir)MiniPost.db"))
    // databases.add(database: sqlite, as: .sqlite)
    // services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    // migrations.add(model: Post.self, database: .sqlite)
    migrations.add(model: Post.self, database: .mysql)
    // migrations.add(model: User.self, database: .sqlite)
    migrations.add(model: User.self, database: .mysql)
    // migrations.add(model: Token.self, database: .sqlite)
    migrations.add(model: Token.self, database: .mysql)
    services.register(migrations)
    // User.PublicUser.defaultDatabase = .sqlite
    User.PublicUser.defaultDatabase = .mysql
}
