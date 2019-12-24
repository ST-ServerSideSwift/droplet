
import Foundation
import FluentPostgreSQL
import Vapor

final class Droplet: Content {
    
    var id: Int?
    var name: String

    init(name: String) {
        self.name = name
    }
}

extension Droplet: PostgreSQLModel {}

extension Droplet: Migration {}

extension Droplet: Parameter {}
