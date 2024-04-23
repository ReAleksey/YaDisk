//
//  ElementCell.swift
//  YaDisk
//
//  Created by Алексей Решетников on 03.04.2024.
//

import Foundation
import UIKit
import SnapKit
import Alamofire

class ElementCell: UITableViewCell {
    static let identifier = "ElementCell"

    lazy var miniImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "photo.on.rectangle.angled")
        return iv
    }()
    lazy var name: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.text = "Header"
        label.numberOfLines = 1
        return label
    }()
    
    lazy var size: UILabel = {
        let label = UILabel()
        label.font = .italicSystemFont(ofSize: 12)
        label.text = "5 мб"
        label.numberOfLines = 1
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .italicSystemFont(ofSize: 12)
        label.text = "2019-05-05"
        label.numberOfLines = 1
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstrains() {
        self.contentView.addSubview(miniImage)
        self.contentView.addSubview(name)
        self.contentView.addSubview(size)
        self.contentView.addSubview(dateLabel)
        
        miniImage.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(miniImage.snp.width).multipliedBy(0.75) // Пропорции 3:4
            make.leading.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
           
        name.snp.makeConstraints { make in
            make.leading.equalTo(miniImage.snp.trailing).offset(16)
            make.top.equalTo(miniImage.snp.top)
            make.trailing.equalToSuperview().inset(16)
        }
        
        size.snp.makeConstraints { make in
            make.leading.equalTo(name.snp.leading)
            make.bottom.equalTo(miniImage.snp.bottom)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(miniImage.snp.bottom)
        }
    }
}
