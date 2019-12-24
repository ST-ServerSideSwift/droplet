import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let dropletsController = DropletsController()
    let usersController = UsersController()
    
    try router.register(collection: dropletsController)
    try router.register(collection: usersController)
    
}
