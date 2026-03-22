//
//  APIServices.swift
//  FoodTrackerApp
//
//  Created by Roman Shevchenko on 27/12/2025.
//

import Foundation

class APIServices {
    static let shared = APIServices()
    
    // Базовый URL вашего сервера
    private let baseURL = "http://localhost:8000"
    
    private init() {}
    
    // MARK: Load Products from Local JSON
    private func loadLocalProducts() throws -> [Product] {
            guard let url = Bundle.main.url(forResource: "products", withExtension: "json") else {
                throw APIError.noData
            }
            
            let data = try Data(contentsOf: url)
            let products = try JSONDecoder().decode([Product].self, from: data)
            print("📦 Loaded \(products.count) products from local JSON")
            return products
        }
    
    // MARK: - Fetch All Products
    func fetchProducts() async throws -> [Product] {
        do {
            guard let url = URL(string: "\(baseURL)/products") else {
                throw APIError.invalidURL
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
                
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError
            }
                
            let products = try JSONDecoder().decode([Product].self, from: data)
            print("✅ Fetched \(products.count) products from server")
            return products
                
        } catch {
            print("⚠️ Failed to fetch from server, loading local JSON: \(error)")
            return try loadLocalProducts()
        }
    }
    
    // MARK: - Search Products
    func searchProducts(query: String) async throws -> [Product] {
        guard !query.isEmpty else {
            return try await fetchProducts()
        }
        
        // Получаем все продукты и фильтруем локально
        // Если ваш сервер поддерживает поиск, можно использовать: /products?search=query
        let allProducts = try await fetchProducts()
        let lowerQuery = query.lowercased()
        
        return allProducts.filter { product in
            product.name.lowercased().contains(lowerQuery)
        }
    }
    
    // MARK: - Get Product by ID
    func getProduct(by id: Int) async throws -> Product? {
        guard let url = URL(string: "\(baseURL)/products/\(id)") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return nil
            }
            
            let product = try JSONDecoder().decode(Product.self, from: data)
            return product
        } catch {
            print("❌ Failed to fetch product \(id): \(error)")
            return nil
        }
    }
}

// MARK: - API Error (Shared)
enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case unauthorized
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .unauthorized:
            return "Unauthorized - check your API key"
        case .serverError:
            return "Server error"
        }
    }
}
