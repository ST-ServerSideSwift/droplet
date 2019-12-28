import Foundation
import FluentPostgreSQL
import Vapor
import Authentication

final class User: Content {
    var id: UUID?
    var name: String
    var userName: String
    var password: String

    init(name: String, userName: String, password: String) {
        self.name = name
        self.userName = userName
        self.password = password
    }

    final class Public: Content {
        var id: UUID?
        var name: String
        var userName: String

        init(id: UUID?, name: String, userName: String) {
            self.id = id
            self.name = name
            self.userName = userName
        }
    }
    
}

extension User {
    
    var droplets: Children<User,Droplet> {
        return children(\.userId)
    }
    
}

extension User: PostgreSQLUUIDModel {}

extension User: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.userName)
        }
    }
    
}

extension User: Parameter {}

extension User {
    
    var Public: User.Public {
        return User.Public(id: id, name: name, userName: userName)
    }
    
}

extension User: BasicAuthenticatable {

    static var usernameKey: UsernameKey = \User.userName
    
    static var passwordKey: PasswordKey = \User.password
    
}

extension User: TokenAuthenticatable {
    
    typealias TokenType = Token
    
}

extension User: PasswordAuthenticatable {}

extension User: SessionAuthenticatable {}

extension Future where T: User {
    
    var Public : Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.Public
        }
    }
    
}


struct AdminUser: Migration {
    
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        let password = try? BCrypt.hash("password")
        guard let hashedPassword = password else {
            fatalError("Failed to create Admin user")
        }
        let user = User(name: "Admin", userName: "admin", password: hashedPassword)
        return user.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
    
}
