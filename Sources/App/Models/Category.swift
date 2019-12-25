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
    
}

extension Category: PostgreSQLModel {}

extension Category: Content {}

extension Category: Migration {}

extension Category: Parameter {}
