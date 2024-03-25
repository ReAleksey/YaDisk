//
//  ProfileProtocol.swift
//  YaDisk
//
//  Created by Алексей Решетников on 15.03.2024.
//

import Foundation

protocol Profile: AnyObject {
    func showInfo (_ diskInfo: DiskInfo)
    func showLoading()
    func hideLoading()
    func showError(_ error: Error)
}
