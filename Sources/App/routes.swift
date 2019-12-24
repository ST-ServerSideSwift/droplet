import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    router.post("api","droplets") { request -> Future<Droplet> in
         try request.content.decode(Droplet.self)
            .flatMap(to: Droplet.self, { (droplet) in
                 droplet.save(on: request)
            })
    }
    
    router.get("api","droplets") { request -> Future<[Droplet]>  in
        Droplet.query(on: request).all()
    }
    
    router.get("api","droplets",Droplet.parameter) { request -> Future<Droplet> in
        try request.parameters.next(Droplet.self)
    }
    
    router.put("api","droplets",Droplet.parameter) { request -> Future<Droplet> in
        try flatMap(to: Droplet.self,
                        request.parameters.next(Droplet.self),
                        request.content.decode(Droplet.self)) { (droplet, updatedDroplet)  in
                            droplet.name = updatedDroplet.name
                            return droplet.save(on: request)
        }
    }
    
    router.delete("api","droplets",Droplet.parameter) { (request) -> Future<HTTPStatus> in
         try request.parameters.next(Droplet.self).delete(on: request).transform(to: .noContent)
    }
    
    router.get("api","droplets","search") { request -> Future<[Droplet]> in
        guard let searchTerm =  request.query[String.self,at: "term"] else {
             throw Abort(.badRequest)
        }
        return Droplet.query(on: request).filter(\.name == searchTerm).all()
    }
    
    router.get("api","droplets","sorted") { request -> Future<[Droplet]> in
        Droplet.query(on: request)
            .sort(\.name, ._ascending)
            .all()
    }
    
    
    
    
    
}
