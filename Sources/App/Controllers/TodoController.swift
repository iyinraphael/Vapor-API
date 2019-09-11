import Vapor
import FluentSQLite

/// Controls basic CRUD operations on `Todo`s.
final class TodoController: RouteCollection {
    
    func boot(router: Router) throws {
        
        //POST a Todo in the httBody, we want to sace it to the database
        
        //baseURL.com/todos/create
        router.post("todos", "create", use: createTodoHandler)
        router.get("todos", "all", use: getAllTodosHandler)
        
        //baseURL.com/todos/
        router.get("todos", Int.parameter, use: getAllTodosHandler )
        
        router.delete("todos", Int.parameter, use: deleteTodoWithIDHandler)
    }
    
    func deleteTodoWithIDHandler(_ req: Request) throws -> Future<HTTPResponseStatus> {
        
        let idParameter = try req.parameters.next(Int.self)
        
        return Todo
            .query(on: req)
            .filter(\.id == idParameter)
            .first()
            .unwrap(or: HTTPError(identifier: "com.LambdaSchool.API", reason: "There's no todo with that identifiers: \(idParameter)"))
            .delete(on: req)
            .transform(to: HTTPResponseStatus.noContent)
    }
    
    func getTodosWithIDHandler(_ req: Request) throws -> Future<Todo> {
        
        let idParameter = try req.parameters.next(Int.self)
        
        return Todo
            .query(on: req)
            .filter(\.id, .equal, idParameter)
            .first()
            .unwrap(or: HTTPError(identifier: "com.LambdaSchool.API", reason: "There's no todo with that identifiers: \(idParameter)"))
        
        
        
    }
    
    func getAllTodosHandler(_ req: Request) throws -> Future<[Todo]> {
        
        //How do we get our tods?
        return Todo.query(on: req).all()
        
    }
    
    func createTodoHandler(_ req: Request) throws -> Future<HTTPResponseStatus> {
       
        return try req.content
            .decode(Todo.self)
            .flatMap({ (todo) -> EventLoopFuture<HTTPResponseStatus> in
            
            // We know that the Todo has been decoded, we can now save it to the database
            _ =  todo.save(on: req)
            
            //You can't initialize a Future so you make a promise
            let promise = req.eventLoop.newPromise(HTTPResponseStatus.self)
            promise.succeed(result: .created)
            
            //The .created result gets returned to the client app
            return promise.futureResult
            })
    }
   
}
