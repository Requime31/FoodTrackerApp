//
//  NutritionAPIManager.swift
//  FoodTrackerApp
//
//  Created by Template
//

import Foundation

// MARK: - Nutrition API Manager
class NutritionAPIManager {
    static let shared = NutritionAPIManager()
    
    // BusyBody API
    private let apiKey = "fn_-ljKfzpRcAmmhXMSFlEMvjEYq9rbc32zyLhwb-ccv44"
    
    // Пробуем разные возможные базовые URL
    // Исправлено: убрано дублирование /api/api/
    private let possibleBaseURLs = [
        "https://busybody.com",
        "https://api.busybody.com",
        "https://busybody.io",
        "https://api.busybody.io"
    ]
    
    private init() {}
    
    // MARK: - Search Foods
    func searchFoods(query: String) async throws -> [Food] {
        guard !query.isEmpty else {
            return []
        }
        
        print("🔍 Searching for: \(query)")
        
        // Сначала пробуем получить данные с вашего сервера
        do {
            let products = try await APIServices.shared.searchProducts(query: query)
            if !products.isEmpty {
                let foods = products.map { $0.toFood() }
                print("✅ Found \(foods.count) foods from your server")
                return foods
            }
        } catch {
            print("⚠️ Failed to fetch from your server: \(error.localizedDescription)")
        }
        
        // Если сервер недоступен, пробуем BusyBody API
        let possibleEndpoints = [
            "/v1/foods/search",
            "/v1/search",
            "/foods/search",
            "/search",
            "/api/v1/foods/search",
            "/api/v1/search",
            "/api/foods/search",
            "/api/search"
        ]
        
        for baseURL in possibleBaseURLs {
            let endpoints: [String]
            if baseURL.contains("/api") {
                endpoints = possibleEndpoints.filter { !$0.hasPrefix("/api") }
            } else {
                endpoints = possibleEndpoints
            }
            
            for endpoint in endpoints {
                do {
                    let foods = try await searchFoodsAtEndpoint(query: query, baseURL: baseURL, endpoint: endpoint)
                    if !foods.isEmpty {
                        print("✅ Found \(foods.count) foods via \(baseURL)\(endpoint)")
                        return foods
                    }
                } catch {
                    print("❌ Error with \(baseURL)\(endpoint): \(error.localizedDescription)")
                    continue
                }
            }
        }
        
        // Если все API не сработали, возвращаем примеры
        print("⚠️ API не вернул результаты, используем примеры продуктов")
        return getExampleFoods(query: query)
    }
    
    private func searchFoodsAtEndpoint(query: String, baseURL: String, endpoint: String) async throws -> [Food] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Пробуем разные варианты параметров запроса
        let queryParams = [
            "?query=\(encodedQuery)",
            "?q=\(encodedQuery)",
            "?search=\(encodedQuery)",
            "?name=\(encodedQuery)",
            "?term=\(encodedQuery)"
        ]
        
        // Пробуем разные варианты авторизации
        let authHeaders = [
            ("Authorization", "Bearer \(apiKey)"),
            ("Authorization", "\(apiKey)"),
            ("X-API-Key", apiKey),
            ("api-key", apiKey),
            ("apikey", apiKey)
        ]
        
        for param in queryParams {
            for (headerName, headerValue) in authHeaders {
                let urlString = "\(baseURL)\(endpoint)\(param)"
                print("🌐 Trying URL: \(urlString) with \(headerName)")
                
                guard let url = URL(string: urlString) else {
                    print("❌ Invalid URL: \(urlString)")
                    continue
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue(headerValue, forHTTPHeaderField: headerName)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.timeoutInterval = 10.0
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Status Code: \(httpResponse.statusCode)")
                    
                    // Проверяем успешный ответ
                    guard (200...299).contains(httpResponse.statusCode) else {
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("❌ Response: \(responseString)")
                        }
                        continue
                    }
                }
                
                // Логируем сырой ответ для отладки
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📦 Response data (first 500 chars): \(String(responseString.prefix(500)))")
                    
                    // Проверяем, не HTML ли это (редирект или веб-страница)
                    if responseString.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("<!DOCTYPE") || 
                       responseString.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("<html") {
                        print("⚠️ Server returned HTML instead of JSON. This might be a redirect or wrong endpoint.")
                        continue
                    }
                }
                
                // Пробуем декодировать как BusyBody ответ
                do {
                    let busyBodyResponse = try JSONDecoder().decode(BusyBodySearchResponse.self, from: data)
                    let foods = busyBodyResponse.foodsArray.map { busyBodyFood in
                        Food(
                            name: busyBodyFood.foodName,
                            calories: busyBodyFood.caloriesValue,
                            protein: busyBodyFood.proteinValue,
                            carbs: busyBodyFood.carbsValue,
                            fat: busyBodyFood.fatValue,
                            servingSize: busyBodyFood.servingSizeValue,
                            brand: busyBodyFood.brand,
                            imageUrl: busyBodyFood.imageUrlValue
                        )
                    }
                    
                    if !foods.isEmpty {
                        print("✅ Decoded \(foods.count) foods from BusyBodySearchResponse")
                        return foods
                    }
                } catch let decodeError {
                    print("⚠️ Failed to decode as BusyBodySearchResponse: \(decodeError.localizedDescription)")
                }
                
                // Пробуем декодировать как массив продуктов напрямую
                do {
                    let foodsArray = try JSONDecoder().decode([BusyBodyFood].self, from: data)
                    let foods = foodsArray.map { busyBodyFood in
                        Food(
                            name: busyBodyFood.foodName,
                            calories: busyBodyFood.caloriesValue,
                            protein: busyBodyFood.proteinValue,
                            carbs: busyBodyFood.carbsValue,
                            fat: busyBodyFood.fatValue,
                            servingSize: busyBodyFood.servingSizeValue,
                            brand: busyBodyFood.brand,
                            imageUrl: busyBodyFood.imageUrlValue
                        )
                    }
                    
                    if !foods.isEmpty {
                        print("✅ Decoded \(foods.count) foods from [BusyBodyFood]")
                        return foods
                    }
                } catch let decodeError {
                    print("⚠️ Failed to decode as [BusyBodyFood]: \(decodeError.localizedDescription)")
                }
                
                // Пробуем декодировать как простой JSON для анализа структуры
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("📋 JSON keys: \(json.keys.joined(separator: ", "))")
                }
                
            } catch let error {
                print("❌ Network error: \(error.localizedDescription)")
                // Продолжаем пробовать другие варианты
                continue
            }
            }
        }
        
        throw APIError.noData
    }
    
    // MARK: - Get Food Details
    func getFoodDetails(foodId: String) async throws -> Food? {
        let possibleEndpoints = [
            "/api/v1/foods/\(foodId)",
            "/api/foods/\(foodId)",
            "/v1/foods/\(foodId)"
        ]
        
        for baseURL in possibleBaseURLs {
            for endpoint in possibleEndpoints {
                let urlString = "\(baseURL)\(endpoint)"
            
            guard let url = URL(string: urlString) else {
                continue
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                
                if let food = try? JSONDecoder().decode(BusyBodyFood.self, from: data) {
                    return Food(
                        name: food.foodName,
                        calories: food.caloriesValue,
                        protein: food.proteinValue,
                        carbs: food.carbsValue,
                        fat: food.fatValue,
                        servingSize: food.servingSizeValue,
                        brand: food.brand,
                        imageUrl: food.imageUrlValue
                    )
                }
            } catch {
                continue
            }
            }
        }
        
        return nil
    }
    
    // MARK: - Example Foods (Fallback)
    private func getExampleFoods(query: String) -> [Food] {
        let examples: [Food] = [
            Food(name: "Apple", calories: 52, protein: 0.3, carbs: 14, fat: 0.2, servingSize: "100g"),
            Food(name: "Banana", calories: 89, protein: 1.1, carbs: 23, fat: 0.3, servingSize: "100g"),
            Food(name: "Chicken Breast", calories: 165, protein: 31, carbs: 0, fat: 3.6, servingSize: "100g"),
            Food(name: "Chicken", calories: 165, protein: 31, carbs: 0, fat: 3.6, servingSize: "100g"),
            Food(name: "Grilled Chicken", calories: 165, protein: 31, carbs: 0, fat: 3.6, servingSize: "100g"),
            Food(name: "Chicken Thigh", calories: 209, protein: 26, carbs: 0, fat: 10, servingSize: "100g"),
            Food(name: "Rice", calories: 130, protein: 2.7, carbs: 28, fat: 0.3, servingSize: "100g"),
            Food(name: "Brown Rice", calories: 111, protein: 2.6, carbs: 23, fat: 0.9, servingSize: "100g"),
            Food(name: "Egg", calories: 155, protein: 13, carbs: 1.1, fat: 11, servingSize: "100g"),
            Food(name: "Bread", calories: 265, protein: 9, carbs: 49, fat: 3.2, servingSize: "100g"),
            Food(name: "Whole Wheat Bread", calories: 247, protein: 13, carbs: 41, fat: 4.2, servingSize: "100g"),
            Food(name: "Milk", calories: 42, protein: 3.4, carbs: 5, fat: 1, servingSize: "100ml"),
            Food(name: "Salmon", calories: 208, protein: 20, carbs: 0, fat: 12, servingSize: "100g"),
            Food(name: "Tuna", calories: 144, protein: 30, carbs: 0, fat: 1, servingSize: "100g"),
            Food(name: "Beef", calories: 250, protein: 26, carbs: 0, fat: 17, servingSize: "100g"),
            Food(name: "Pork", calories: 242, protein: 27, carbs: 0, fat: 14, servingSize: "100g"),
        ]
        
        let lowerQuery = query.lowercased()
        if lowerQuery.isEmpty {
            return examples
        }
        
        // Фильтруем по запросу
        let filtered = examples.filter { $0.name.lowercased().contains(lowerQuery) }
        
        // Если ничего не найдено, возвращаем все примеры
        return filtered.isEmpty ? examples : filtered
    }
}

// APIError определен в APIServices.swift
