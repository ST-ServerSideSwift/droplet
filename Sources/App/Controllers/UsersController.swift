
import Foundation
import Vapor
import Crypto

struct UsersController: RouteCollection {
    
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        usersRoute.post(User.self, use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User.parameter,use:getHandler)
        
        usersRoute.get(User.parameter,"droplets", use: getDropletsHandler)
    }
    
    
    func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req).Public
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).Public
    }
    
    func getDropletsHandler(_ req: Request) throws -> Future<[Droplet]> {
        return try req.parameters.next(User.self).flatMap(to: [Droplet].self, { user in
            try user.droplets.query(on: req).all()
        })
    }
    
}
