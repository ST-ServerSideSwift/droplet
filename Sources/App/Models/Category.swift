//
//  Category.swift
//  App
//
//  Created by subash on 12/24/19.
//

import Foundation
import FluentPostgreSQL
import Vapor

final class Category: Codable {
    var id: Int?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Category {
    
    var droplets: Siblings<Category,Droplet,DropletCategoryPivot> {
        return siblings()
    }
    
    static func addCategory(_ name: String, to droplet: Droplet, on req: Request) throws -> Future<Void> {
        return Category.query(on: req).filter(\.name == name).first()
            .flatMap(to: Void.self) { foundCategory in
                if let existingCategory = foundCategory {
                    return droplet.categories.attach(existingCategory, on: req).transform(to: ())
                } else {
                    let category = Category(name: name)
                    return category.save(on: req).flatMap(to: Void.self) { savedCategory in
                        return droplet.categories.attach(savedCategory, on: req).transform(to: ())
                    }
                }
        }
    }
    
}

extension Category: PostgreSQLModel {}

extension Category: Content {}

extension Category: Migration {}

extension Category: Parameter {}
