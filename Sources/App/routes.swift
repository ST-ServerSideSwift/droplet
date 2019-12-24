import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let dropletController = DropletController()
    try router.register(collection: dropletController)
    
}
