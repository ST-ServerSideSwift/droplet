import Foundation
import Vapor

struct DropletsController: RouteCollection {
    
    func boot(router: Router) throws {
        let dropletRoute = router.grouped("api","droplets")
        
        dropletRoute.get(use: getAllHandler)
        dropletRoute.get(Droplet.parameter, use: getHandler)
        dropletRoute.post(use: createHandler)
        dropletRoute.put(Droplet.parameter, use: updateHandler)
        dropletRoute.delete(Droplet.parameter, use: deleteHandler)
        dropletRoute.get("sorted", use: sortHandler)
        
        dropletRoute.get(Droplet.parameter,"user",use: getUserHandler)
    }
    
    //Get: all
    func getAllHandler(_ request: Request) throws -> Future<[Droplet]> {
        return Droplet.query(on: request).all()
    }
    
    //Get: specific droplet
    func getHandler(_ request: Request) throws -> Future<Droplet> {
        try request.parameters.next(Droplet.self)
    }
    
    //Post: droplet
    func createHandler(_ request: Request) throws -> Future<Droplet> {
        try flatMap(to: Droplet.self,
                    request.parameters.next(Droplet.self),
                    request.content.decode(Droplet.self)) { (droplet, updatedDroplet)  in
                        droplet.name = updatedDroplet.name
                        return droplet.save(on: request)
        }
    }
    
    //Put: Update a droplet
    func updateHandler(_ request: Request) throws -> Future<Droplet> {
        try flatMap(to: Droplet.self,
                    request.parameters.next(Droplet.self),
                    request.content.decode(Droplet.self)) { (droplet, updatedDroplet)  in
                        droplet.name = updatedDroplet.name
                        droplet.userId = updatedDroplet.userId
                        return droplet.save(on: request)
        }
    }
    
    ///Delete: specific droplet
    func deleteHandler(_ request: Request) throws -> Future<HTTPStatus> {
        try request.parameters.next(Droplet.self).delete(on: request).transform(to: .noContent)
    }
    
    //Sort
    func sortHandler(_ request: Request) throws -> Future<[Droplet]> {
        return Droplet.query(on: request)
                   .sort(\.name, ._ascending)
                   .all()
    }
    
    //Get associated User
    func getUserHandler(_ request: Request) throws -> Future<User> {
        try request.parameters.next(Droplet.self).flatMap(to: User.self) { droplet in
            droplet.user.get(on: request)
        }
    }
    
    
}
