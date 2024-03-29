//
//  JSONManager.swift
//  YaDisk
//
//  Created by Алексей Решетников on 11.03.2024.
//

import Foundation

struct DiskInfo: Decodable {
    let trash_size: Float
    let total_space: Float
    let used_space: Float
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
}

struct ResourceList: Decodable {
    let items: [Resource]?
    
    let sort: String?
    let public_key: String?
    let limit: String?
    let offset: String?
    let path: String?
    let total: String?
}

