//
//  CreateProduct.swift
//  
//
//  Created by Александр Макаров on 16.03.2023.
//

import Vapor
import Fluent

struct CreateProduct: AsyncMigration {
    
    func prepare(on database: FluentKit.Database) async throws {
        let schema = database.schema("products")
            .id()
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("price", .int, .required)
            .field("category", .string, .required)
            .field("image", .string, .required)
        
        try await schema.create()
    }
    
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema("products").delete()
    }
}
