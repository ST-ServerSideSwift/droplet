import Vapor
import FluentPostgreSQL
import Authentication

final class Token: Content {
    var id: UUID?
    var token: String
    var userId: User.ID

    init(token: String, userId: User.ID) {
        self.token = token
        self.userId = userId
    }
}

extension Token {
    
    static func generate(for user: User) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(), userId: user.requireID())
    }
    
}

extension Token: Authentication.Token {
   
    typealias UserType = User
    static var userIDKey: UserIDKey = \Token.userId
    static var tokenKey: TokenKey = \Token.token
    
}



extension Token: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userId, to: \User.id)
        }
    }
    
}

extension Token: PostgreSQLUUIDModel {}
