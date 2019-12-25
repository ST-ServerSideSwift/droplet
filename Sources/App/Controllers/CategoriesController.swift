//
//  CategoriesController.swift
//  App
//
//  Created by subash on 12/24/19.
//

import Foundation
import Vapor

struct CategoriesController: RouteCollection {
    
    func boot(router: Router) throws {
        let categoriesRoute = router.grouped("api","categories")
        categoriesRoute.post(Category.self, use: createHandler)
        categoriesRoute.get(use: getAllHandler)
        categoriesRoute.get(Category.parameter, use: getHandler)
        
        categoriesRoute.get(Category.parameter,"droplets", use: getDropletsHandler)
    }
    
    func createHandler(_ req: Request, category: Category) throws -> Future<Category> {
        return category.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Category]> {
        return Category.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Category> {
        return try req.parameters.next(Category.self)
    }
    
    func getDropletsHandler(_ req: Request) throws -> Future<[Droplet]> {
        return try req.parameters.next(Category.self)
            .flatMap(to: [Droplet].self) { category in
                try category.droplets.query(on: req).all()
        }
    }
}


