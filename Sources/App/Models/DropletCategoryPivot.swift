//
//  DropletCategoryPivot.swift
//  App
//
//  Created by subash on 12/24/19.
//

import Foundation
import FluentPostgreSQL
import Vapor

final class DropletCategoryPivot: PostgreSQLUUIDPivot, ModifiablePivot {
    
    var id: UUID?
    
    var dropletId: Droplet.ID
    var categoryId: Category.ID
    
    typealias Left = Droplet
    typealias Right = Category
    
    static var leftIDKey: LeftIDKey = \.dropletId
    static var rightIDKey: RightIDKey = \.categoryId
    
    init(_ droplet: Droplet, _ category: Category) throws {
        self.dropletId = try droplet.requireID()
        self.categoryId = try category.requireID()
    }

}

extension DropletCategoryPivot: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.dropletId, to: \Droplet.id, onDelete: .cascade)
            builder.reference(from: \.categoryId, to: \Category.id, onDelete: .cascade)
        }
    }
    
}







