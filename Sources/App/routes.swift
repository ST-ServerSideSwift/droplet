import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let dropletsController = DropletsController()
    let usersController = UsersController()
    let categoriesController = CategoriesController()
    let websiteController = WebsiteController()
    
    try router.register(collection: dropletsController)
    try router.register(collection: usersController)
    try router.register(collection: categoriesController)
    try router.register(collection: websiteController)
}
