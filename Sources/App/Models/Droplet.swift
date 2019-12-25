
import Foundation
import FluentPostgreSQL
import Vapor

final class Droplet: Content {
    
    var id: Int?
    var name: String
    var userId: User.ID

    init(name: String, userId: User.ID) {
        self.name = name
        self.userId = userId
    }
}

extension Droplet {
    
    var user: Parent<Droplet, User> {
        return parent(\.userId)
    }
    
    var categories: Siblings<Droplet,Category,DropletCategoryPivot> {
        return siblings()
    }
    
}

extension Droplet: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userId, to: \User.id)
        }
    }
    
}

extension Droplet: PostgreSQLModel {}

extension Droplet: Parameter {}
