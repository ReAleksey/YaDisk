//
//  ProfilePresenter.swift
//  YaDisk
//
//  Created by Алексей Решетников on 15.03.2024.
//

import Foundation

class Presenter: ProfilePresenterProtocol {
    
    weak var view: Profile?
    var model: DiskModelProtocol
    
    init(view: Profile) {
        self.view = view
        self.model = DiskModel()
    }
    
    func getDiskInfo() {
        view?.showLoading()

        model.getDiskInfo { [weak self] diskInfo, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.view?.hideLoading()
                
                if let error = error {
                    self.view?.showError(error)
                } else if let diskInfo = diskInfo {
                    self.view?.showInfo(diskInfo)
                }
            }
        }
    }
    
    
}

