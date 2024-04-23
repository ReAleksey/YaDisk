//
//  TestAPIVC.swift
//  YaDisk
//
//  Created by Алексей Решетников on 19.04.2024.
//

import Foundation
import UIKit

class TestAPIVC: UIViewController {
    
    // Функция для отправки запроса к API Яндекс.Диска
    func fetchFromYandexDisk(path: String, limit: Int, offset: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        // Создание URLComponents с базовым URL
        guard var urlComponents = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/\(path)") else {
            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            print("Error: Invalid URL - \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        // Добавление параметров запроса
        urlComponents.queryItems = [
            URLQueryItem(name: "path", value: path),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "fields", value: "name,type,created,modified,path,size,mime_type,preview,public_key,public_url,_embedded.items,custom_properties")
        ]
        
        // Создание запроса
        guard let url = urlComponents.url else {
            let error = NSError(domain: "Invalid URL", code: 1, userInfo: nil)
            print("Error: Could not construct URL - \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        // Настройка запроса
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("y0_AgAAAAAkCDffAAuG_gAAAAEAIT3BAADR8oAHnTZF4aBhf7m57hD2wqFbPQ", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        
        // Отправка запроса
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "Data Error", code: 2, userInfo: nil)
                print("Error: No data received - \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("Response: \(String(describing: String(data: data, encoding: .utf8)))")
            completion(.success(data))
        }
        
        task.resume()
    }
   
    override func viewDidLoad() {
        // Пример вызова функции
        fetchFromYandexDisk(path: "resources/files", limit: 10, offset: 0) { result in
            switch result {
            case .success(let data):
                // Обработка полученных данных
                print("Data received: \(data)")
            case .failure(let error):
                // Обработка ошибки
                print("Error: \(error.localizedDescription)")
            }
        }
    }

}
