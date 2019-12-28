//
//  WebsiteController.swift
//  App
//
//  Created by subash on 12/24/19.
//

import Foundation
import Vapor
import Authentication

struct WebsiteController: RouteCollection {

  func boot(router: Router) throws {

    let authSessionRoutes = router.grouped(User.authSessionsMiddleware())

     authSessionRoutes.get(use: indexHandler)
     authSessionRoutes.get("droplets",Droplet.parameter, use: dropletHandler)
     authSessionRoutes.get("users",User.parameter,use: userHandler)
     authSessionRoutes.get("users",use: allUsersHandler)
     authSessionRoutes.get("categories", use: allCategoriesHandler)
     authSessionRoutes.get("categories",Category.parameter, use: categoryHandler)
     authSessionRoutes.get("login",use: loginHandler)
     authSessionRoutes.post(LoginPostData.self,at:"login", use: loginPostHandler)
     authSessionRoutes.post("logout", use: logoutHandler)
    
     let protectedRoutes = authSessionRoutes.grouped(RedirectMiddleware<User>(path: "/login")  )
     protectedRoutes.get("droplets","create", use: createDropletHandler)
     protectedRoutes.post(createDropletData.self, at: "droplets","create", use: createDropletPostHandler)
     protectedRoutes.get("droplets",Droplet.parameter,"edit", use: editDropletHandler)
     protectedRoutes.post("droplets",Droplet.parameter,"edit", use: editDropletPostHandler)
     protectedRoutes.post("droplets",Droplet.parameter,"delete", use: deleteDropletHandler)
    
  }

  func indexHandler(_ req: Request) throws -> Future<View> {
    return Droplet.query(on: req).all()
        .flatMap(to: View.self) { droplets in
            let userLoggedIn = try req.isAuthenticated(User.self)
            let context = IndexContext(title: "Home Page",droplets: droplets, userLoggedIn: userLoggedIn)
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
    
    func createDropletHandler(_ req: Request) throws -> Future<View> {
        let context = CreateDropletContext()
        return try req.view().render("createDroplet", context)
    }
    
    func createDropletPostHandler(_ req: Request, dropletData: createDropletData) throws -> Future<Response> {
        let user = try req.requireAuthenticated(User.self)
        let droplet = try Droplet(name: dropletData.name, userId: user.requireID())
        return droplet.save(on: req).map(to: Response.self) { droplet in
            guard let id = droplet.id else {
                throw Abort(.internalServerError)
            }
            return req.redirect(to: "/droplets/\(id)")
        }
    }
    
    func editDropletHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Droplet.self)
            .flatMap(to: View.self, { droplet in
                let context = EditDropletContext(droplet: droplet)
                //note leaf is same as create
                return try req.view().render("createDroplet", context)
            })
    }
    
    func editDropletPostHandler(_ req: Request) throws -> Future<Response> {
        return try flatMap(to: Response.self,
                           req.parameters.next(Droplet.self),
                           req.content.decode(Droplet.self), { droplet, newData in

                            let user = try req.requireAuthenticated(User.self)
                            droplet.name = newData.name
                            droplet.userId = try user.requireID()
                            
                            guard let id = droplet.id else {
                                throw Abort(.internalServerError)
                            }
                            let redirect = req.redirect(to: "/droplets/\(id)")
                            return droplet.save(on: req).transform(to: redirect)
        })
    }
    
    func deleteDropletHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Droplet.self).delete(on: req).transform(to: req.redirect(to: "/"))
    }
    
    func loginHandler(_ req: Request) throws -> Future<View> {
        let context: LoginContext
        if req.query[Bool.self,at: "error"] != nil {
            context = LoginContext(loginError: true)
        } else {
            context = LoginContext()
        }
        return try req.view().render("login", context)
    }
    
    func loginPostHandler(_ req: Request, userData: LoginPostData) throws -> Future<Response> {
        return User.authenticate(username: userData.userName, password: userData.password, using: BCryptDigest(), on: req)
            .map(to: Response.self) { user in
                guard let user = user else {
                    return req.redirect(to: "/login?error")
                }
                try req.authenticateSession(user)
                return req.redirect(to: "/")
        }
    }
    
    func logoutHandler(_ req: Request) throws -> Response {
        try req.unauthenticate(User.self)
        return req.redirect(to: "/")
    }

    
    
}

struct IndexContext: Encodable {
    let title: String
    let droplets: [Droplet]
    let userLoggedIn: Bool
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

struct CreateDropletContext: Encodable {
    let title = "Create a Droplet"
}

struct EditDropletContext: Encodable {
    let title = "Edit Droplet"
    let droplet: Droplet
    let editing = true
}

struct LoginContext: Encodable {
    let title = "Log In"
    let loginError: Bool

    init(loginError: Bool = false) {
        self.loginError = loginError
    }
}

struct LoginPostData: Content {
    let userName: String
    let password: String
}

struct createDropletData: Content {
    var name: String
}
