//
//  OldDiskModel.swift
//  YaDisk
//
//  Created by Алексей Решетников on 24.04.2024.
//

import Foundation
import UIKit
import Alamofire

class OldDiskModel: ObservableObject {
    
    func loadToken(completion: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: "https://oauth.yandex.ru/authorize?response_type=token&client_id=YOUR_CLIENT_ID&redirect_uri=YOUR_REDIRECT_URI") else {
            completion(nil, NSError(domain: "URL Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            // Печатаем ответ сервера для диагностики
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                       let token = json["access_token"] as? String {
                        completion(token, nil)
                    } else {
                        completion(nil, NSError(domain: "Token Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Token not found in response"]))
                    }
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, NSError(domain: "Data Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received or failed to decode data"]))
            }
        }
        
        task.resume()
    }
    
        func newFetchData(forPath path: String = "", limit: Int = 1000, offset: Int = 0, completion: @escaping (ApiResponse?, Error?) -> Void) {
            // Создаем URL с добавлением query параметров
            guard var urlComponents = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/\(path)") else {
                let error = NSError(domain: "Invalid URL", code: 0)
                print("Error: Invalid URL - \(error.localizedDescription)")
                completion(nil, error)
                return
            }
    
            // Добавляем параметры запроса
            urlComponents.queryItems = [
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "offset", value: String(offset)),
                URLQueryItem(name: "fields", value: "name,_embedded.items.path,created")  // Уточняем, какие поля нам нужны
    
            ]
    
            // Проверяем, что URL сформирован правильно
            guard let url = urlComponents.url else {
                let error = NSError(domain: "Invalid URL", code: 0)
                print("Error: Invalid URL - \(error.localizedDescription)")
                completion(nil, error)
                return
            }
    
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("y0_AgAAAAAkCDffAAuG_gAAAAEAIT3BAADR8oAHnTZF4aBhf7m57hD2wqFbPQ", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
            print("Sending request with limit \(limit) and offset \(offset)...")
    
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
    
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }
    
                guard let httpResponse = response as? HTTPURLResponse else {
                    let error = NSError(domain: "Invalid Response", code: 1)
                    print("Error: Invalid HTTP Response")
                    completion(nil, error)
                    return
                }
    
                print("Response status code: \(httpResponse.statusCode)")
    
                if let data = data {
                    do {
                        let decodedResponse = try decoder.decode(ApiResponse.self, from: data)
                        completion(decodedResponse, nil)
                    } catch {
                        print("Error decoding JSON: \(error)")
                        completion(nil, error)
                    }
                } else {
                    let error = NSError(domain: "Invalid Response Data", code: 2)
                    print("Error: Invalid Response Data")
                    completion(nil, error)
                }
            }
            task.resume()
        }
    
    func loadFile(forPath path: String = "", completion: @escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: "https://downloader.disk.yandex.ru/preview/7fec581a980952586e9ce306b1f1eeca8781fed10be29aa14008bfbd6e8dc523/inf/xJNPjg0BOUNC4vBJCJaNkat1wMpzL-sKVsTbcYrfJtLyd0TIsw-yB6QIsqXMpF2U210J-u942Ow8OrZKe4kh5A%3D%3D?uid=604518367&filename=IMG_9692.JPG&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&owner_uid=604518367&tknv=v2&size=S&crop=0\(path)") else {
            let error = NSError(domain: "Invalid URL", code: 0)
            print("Error: Invalid URL - \(error.localizedDescription)")
            completion(nil, error)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("y0_AgAAAAAkCDffAAuG_gAAAAEAIT3BAADR8oAHnTZF4aBhf7m57hD2wqFbPQ", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Sending request...")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "Invalid Response", code: 1)
                print("Error: Invalid HTTP Response")
                completion(nil, error)
                return
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            
            if let data = data {
                do {
                    //                    let decodedResponse = try JSONDecoder().decode(ResourceList.self, from: data)
                    completion(data, nil)
                } catch {
                    print("Error decoding JSON: \(error)")
                    completion(nil, error)
                }
            } else {
                let error = NSError(domain: "Invalid Response Data", code: 2)
                print("Error: Invalid Response Data")
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    func loadImage(adress: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: adress) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("y0_AgAAAAAkCDffAAuG_gAAAAEAIT3BAADR8oAHnTZF4aBhf7m57hD2wqFbPQ", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print("Trying to load image...")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                print("Error loading image: \(error)")
                completion(nil)
                return
            }
            
            guard (200...299).contains(response.statusCode) else {
                print("Server error: \(response.statusCode)")
                completion(nil)
                return
            }
            
            if let image = UIImage(data: data) {
                completion(image)
            } else {
                print("Failed to convert data to UIImage")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
//    func lastFiles(completion: @escaping ([Resource]?, Error?) -> Void) {
//        guard let url = URL(string: "https://cloud-api.yandex.net/v1/disk/resources/last-uploaded") else {
//            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
//            print("Error: Invalid URL - \(error.localizedDescription)")
//            completion(nil, error)
//            return
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("y0_AgAAAAAkCDffAAuG_gAAAAEAIT3BAADR8oAHnTZF4aBhf7m57hD2wqFbPQ", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("10", forHTTPHeaderField: "limit")
//        request.setValue("image", forHTTPHeaderField: "media_type")
//        request.setValue("name,_embedded.items.path", forHTTPHeaderField: "fields")
//        request.setValue("", forHTTPHeaderField: "preview_size")
//        request.setValue("false", forHTTPHeaderField: "preview_crop")
//
//        print("Sending request...")
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                completion(nil, error)
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                let error = NSError(domain: "Invalid Response", code: 1)
//                print("Error: Invalid HTTP Response")
//                completion(nil, error)
//                return
//            }
//
//            print("Response status code: \(httpResponse.statusCode)")
//
//            if let data = data, let decodedResponse = try? JSONDecoder().decode(ResourceList.self, from: data) {
//                completion(decodedResponse.items, nil)
//            } else {
//                let error = NSError(domain: "Invalid Response Data", code: 2)
//                print("Error: Invalid Response Data")
//                completion(nil, error)
//            }
//        }
//        task.resume()
//    }
}
