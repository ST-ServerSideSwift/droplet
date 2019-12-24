import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    router.post("api","droplet") { request -> Future<Droplet> in
         try request.content.decode(Droplet.self)
            .flatMap(to: Droplet.self, { (droplet) in
                 droplet.save(on: request)
            })
    }
    
}
