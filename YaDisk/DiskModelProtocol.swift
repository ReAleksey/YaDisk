//
//  DiskModelProtocol.swift
//  YaDisk
//
//  Created by Алексей Решетников on 11.03.2024.
//

import Foundation

protocol DiskModelProtocol {
    func getDiskInfo(completion: @escaping (DiskInfo?, Error?) -> Void)
    func fetchData(forPath path: String, limit: Int, offset: Int, completion: @escaping ([Resource]?, Error?) -> Void)
}
