//
//  JSONManager.swift
//  YaDisk
//
//  Created by Алексей Решетников on 11.03.2024.
//

import Foundation

struct DiskInfo: Decodable {
    let trash_size: Double
    let total_space: Double
    let used_space: Double
    let system_folders: SystemFolders
}

struct SystemFolders: Decodable {
    let applications: String
    let downloads: String
}

struct Resource: Decodable {
    let name: String
    let type: String
    let created: String
    let modified: String
    let path: String
    let size: Int?
    let mime_type: String?
    let preview: String?
    let public_key: String?
    let public_url: String?
    let _embedded: String?
    let custom_properties: String?
}

struct ResourceList: Decodable {
    let items: [Resource]?
    let sort: String?
    let public_key: String?
    let limit: Int?
    let offset: Int?
    let path: String?
    let total: String?
}
