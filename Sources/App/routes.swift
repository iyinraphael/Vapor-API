import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
       // Example of configuring a controller
    let todoController = TodoController()
    
    try router.register(collection: todoController)
   
}
