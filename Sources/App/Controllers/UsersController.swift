//
//  File.swift
//  
//
//  Created by Александр Макаров on 17.03.2023.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let usersGroup = routes.grouped("users")
        usersGroup.post(use: createHandler)
        usersGroup.get(use: getAllHandler)
        usersGroup.get(":id", use: getAllHandler)
    }
    
    func createHandler(_ req: Request) async throws -> User.Public {
        guard let user = try? req.content.decode(User.self) else {
            throw Abort(.custom(code: 498, reasonPhrase: "Не удалось создать юзера"))
        }
        
        user.password = try Bcrypt.hash(user.password)
        try await user.save(on: req.db)
        return user.convertToPublic()
    }
    
    func getAllHandler(_ req: Request) async throws -> [User.Public] {
        let users = try await User.query(on: req.db).all()
        return users.map { $0.convertToPublic() }
    }
    
    func getHandler(_ req: Request) async throws -> User.Public {
        guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return user.convertToPublic()
    }
}
