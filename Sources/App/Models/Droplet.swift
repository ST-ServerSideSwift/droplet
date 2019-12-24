
import Foundation
import FluentSQLite
import Vapor

final class Droplet: Content {
    
    var id: Int?
    var name: String

    init(name: String) {
        self.name = name
    }
}

extension Droplet: SQLiteModel {}

extension Droplet: Migration {}
