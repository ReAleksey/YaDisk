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

