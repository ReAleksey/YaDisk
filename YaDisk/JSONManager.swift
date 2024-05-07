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

// Основная структура ответа
struct ApiResponse: Decodable {
    let items: [Item]
}

// Структура для каждого элемента в массиве "items"
struct Item: Decodable {
    let antivirusStatus: String
    let size: Int
    let commentIds: CommentIDs
    let name: String
    let exif: ExifData?
    let created: String
    let resourceID: String
    let modified: String
    let mimeType: String
    let sizes: [ImageSize]?
    let file: String
    let preview: String?
    let path: String
    let sha256: String
    let type: String
    let md5: String
    let revision: Int
    
    enum CodingKeys: String, CodingKey {
        case antivirusStatus = "antivirus_status"
        case size
        case commentIds = "comment_ids"
        case name
        case exif
        case created
        case resourceID = "resource_id"
        case modified
        case mimeType = "mime_type"
        case sizes
        case file
        case preview
        case path
        case sha256
        case type
        case md5
        case revision
    }
}

// Структура для "comment_ids"
struct CommentIDs: Decodable {
    let privateResource: String
    let publicResource: String
    
    enum CodingKeys: String, CodingKey {
        case privateResource = "private_resource"
        case publicResource = "public_resource"
    }
}

// Структура для "exif"
struct ExifData: Decodable {
    let dateTime: String?
    
    enum CodingKeys: String, CodingKey {
        case dateTime = "date_time"
    }
}

// Структура для массива "sizes"
struct ImageSize: Decodable {
    let url: String
    let name: String
}


