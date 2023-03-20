//
//  User.swift
//  
//
//  Created by Александр Макаров on 17.03.2023.
//

import Vapor
import Fluent

final class User: Model, Content {
    static var schema = "users"
    
    @ID var id: UUID?
    @Field(key: "name") var name: String
    @Field(key: "login") var login: String
    @Field(key: "password") var password: String
    @Field(key: "role") var role: String
    @Field(key: "profilePic") var profilePic: String
    
    final class Public: Content {
        
        var id: UUID?
        var login: String
        var role: String
        var profilePic: String?
        
        init(id: UUID? = nil, login: String, role: String, profilePic: String? = nil) {
            self.id = id
            self.login = login
            self.role = role
            self.profilePic = profilePic
        }
    }
}


extension User {
    func convertToPublic() -> User.Public {
        let pub = User.Public(id: self.id,
                              login: self.login,
                              role: self.role,
                              profilePic: self.profilePic)
        return pub
    }
}

// Определяем user как идентифицируемую модель

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$login
    
    static var passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
    
    
}

enum UserRole: String {
    case officiant = "Официант"
    case manager =  "Менеджер"
}
