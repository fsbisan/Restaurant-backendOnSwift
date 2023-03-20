//
//  Product.swift
//  
//
//  Created by Александр Макаров on 16.03.2023.
//

import Fluent
import Vapor


final class Product: Model, Content {
    
    static var schema: String = "products"
    
    @ID(key: .id) var id: UUID?
    @Field(key: "title") var title: String
    @Field(key: "description") var description: String
    @Field(key: "price") var price: Int
    @Field(key: "category") var category: String
    @Field(key: "image") var image: String
    
    init() {}
    
    init(id: UUID? = nil, title: String, description: String, price: Int, category: String, image: String) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.category = category
        self.image = image
    }
}
