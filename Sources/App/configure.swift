import FluentPostgreSQL
import Vapor
import Leaf
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    ////Leaf
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    ///Authentication
    try services.register(AuthenticationProvider())

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)

    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let database = Environment.get("DATABASE_DB") ?? "vapor"
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    let postgreDatabaseConfig = PostgreSQLDatabaseConfig(hostname: hostname,
                                                         username: username,
                                                         database: database,
                                                         password: password)
    let postgreDatabase = PostgreSQLDatabase(config: postgreDatabaseConfig)
    databases.add(database: postgreDatabase, as: .psql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Droplet.self, database: .psql)
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: DropletCategoryPivot.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    migrations.add(migration: AdminUser.self, database: .psql)
    services.register(migrations)

    //Add fluents command tp CommandConfig
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
    
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
}
