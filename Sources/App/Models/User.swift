import Foundation
import FluentPostgreSQL
import Vapor

final class User: Codable {
    var id: UUID?
    var name: String
    var userName: String

    init(name: String, userName: String) {
        self.name = name
        self.userName = userName
    }
}

extension User {
    
    var droplets: Children<User,Droplet> {
        return children(\.userId)
    }
    
}

extension User: Content {}

extension User: PostgreSQLUUIDModel {}

extension User: Migration {}

extension User: Parameter {}
