//
//  WebsiteController.swift
//  App
//
//  Created by subash on 12/24/19.
//

import Foundation
import Vapor

struct WebsiteController: RouteCollection {

  func boot(router: Router) throws {
     router.get(use: indexHandler)
     router.get("droplets",Droplet.parameter, use: dropletHandler)
     router.get("users",User.parameter,use: userHandler)
     router.get("users",use: allUsersHandler)
     router.get("categories", use: allCategoriesHandler)
     router.get("categories",Category.parameter, use: categoryHandler)
      
  }

  func indexHandler(_ req: Request) throws -> Future<View> {
    return Droplet.query(on: req).all()
        .flatMap(to: View.self) { droplets in
            let context = IndexContext(title: "Home Page",droplets: droplets)
            return try req.view().render("index",context)
    }
  }
    
   
    func dropletHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Droplet.self)
            .flatMap(to: View.self, { droplet in
                return droplet.user.get(on: req)
                    .flatMap(to: View.self) { user in
                        let context = DropletContext(title: droplet.name, droplet: droplet, user: user)
                        return try req.view().render("droplet", context)
                }
            })
    }
    
    
    func userHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(User.self)
            .flatMap(to: View.self) { user in
                return try user.droplets.query(on: req).all()
                    .flatMap(to: View.self) { droplets in
                        let context = UserContext(title: user.name,
                                                  user: user,
                                                  droplets: droplets)
                        return try req.view().render("user",context)
                }
        }
    }
    
    func allUsersHandler(_ req: Request) throws -> Future<View> {
        return User.query(on: req).all()
            .flatMap(to: View.self) { users in
                let context = AllUsersContext(title: "All Users", users: users)
                return try req.view().render("allUsers", context)
        }
    }
    
    func allCategoriesHandler(_ req: Request) throws -> Future<View> {
        let categories = Category.query(on: req).all()
        let context = AllCategoriesContext(categories: categories)
        return try req.view().render("allCategories", context)
    }
    
    func categoryHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Category.self)
            .flatMap(to: View.self) { category  in
                let droplets = try category.droplets.query(on: req).all()
                let context = CategoryContext(title: category.name, category: category, droplets: droplets)
                return try req.view().render("category",context)
            }
    }

    
    
}

struct IndexContext: Encodable {
    let title: String
    let droplets: [Droplet]
}

struct DropletContext: Encodable {
    let title: String
    let droplet: Droplet
    let user: User
}

struct UserContext: Encodable {
    let title: String
    let user: User
    let droplets: [Droplet]
}

struct AllUsersContext: Encodable {
  let title: String
  let users: [User]
}

struct AllCategoriesContext: Encodable {
    let title:String = "All Categories"
    let categories: Future<[Category]>
}

struct CategoryContext: Encodable {
    let title: String
    let category: Category
    let droplets: Future<[Droplet]>
}

