//
//  ProductsController.swift
//  
//
//  Created by Александр Макаров on 17.03.2023.
//

import Fluent
import Vapor

struct ProductsController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let productGroup = routes.grouped("products")
        
        productGroup.get(use: getAllHandler)
        productGroup.get(":productID", use: getHandler)
        
        let basicMW = User.authenticator()
        let guardMW = User.guardMiddleware()
        
        // Создаем группу маршрутов которая будет защищенная
        let protected = productGroup.grouped(basicMW, guardMW)
        protected.post(use: createHandler)
        protected.delete(":productID", use: deleteHandler)
        protected.put(":productID", use: updateHandler)
    }
    
    // MARK: - CRUD - Create
    func createHandler(_ req: Request) async throws -> Product {
        
        guard let productData = try? req.content.decode(ProductsDTO.self) else {
            throw Abort(.custom(code: 499, reasonPhrase: "Не получилось екодировать контент в модель ДТО продукта"))
        }
        
        let productID = UUID()
        let product = Product(id: productID,
                              title: productData.title,
                              description: productData.description,
                              price: productData.price,
                              category: productData.category,
                              image: "")
        
        // Рабочая папка проекта через Edit scheme выбирается
        let imagePath = req.application.directory.workingDirectory + "/Storage/Products" + "/\(product.id!).jpg"
        
        try await req.fileio.writeFile(.init(data: productData.image), at: imagePath)
        product.image = imagePath
        
        try await product.save(on: req.db)
        return product
    }
    
    // MARK: - CRUD - Retrieve All
    func getAllHandler(_ req: Request) async throws -> [Product] {
        let products = try await Product.query(on: req.db).all()
        return products
    }
    
    // MARK: - CRUD - Retrieve
    func getHandler(_ req: Request) async throws -> Product {
        guard let product = try await Product.find(req.parameters.get("productID"),
                                                   on: req.db) else {
            throw Abort(.notFound)
        }
        return product
    }
    // MARK: - CRUD - Update
    
    func updateHandler(_ req: Request) async throws -> Product {
        guard let product = try await Product.find(req.parameters.get("productID"),
                                                   on: req.db) else {
            throw Abort(.notFound)
        }
        let updatedProduct = try req.content.decode(Product.self)
        product.title = updatedProduct.title
        product.price = updatedProduct.price
        product.category = updatedProduct.category
        product.description = updatedProduct.description
        product.image = updatedProduct.image
        try await product.save(on: req.db)
        return product
    }
    
    // MARK: - CRUD - Delete
    func deleteHandler(_ req: Request) async throws -> HTTPStatus {
        guard let product = try await Product.find(req.parameters.get("productID"), on: req.db) else {
            throw Abort(.notFound, reason: "Продукт не найден для удаления")
        }
        try await product.delete(on: req.db)
        return .ok
    }
}

struct ProductsDTO: Content {
    var title: String
    var description: String
    var price: Int
    var category: String
    var image: Data
}
