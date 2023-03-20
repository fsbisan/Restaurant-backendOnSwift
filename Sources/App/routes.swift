import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: ProductsController())
    try app.register(collection: UserController())
    app.routes
        .defaultMaxBodySize = "5Mb"
}
