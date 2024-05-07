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
import AlamofireImage

class ElementCell: UITableViewCell {
    static let identifier = "ElementCell"

    var miniImage =  UIImageView()
    
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
    
    func configure(with item: Item) {
        name.text = item.name
        size.text = formatFileSize(item.size)
        dateLabel.text = formatDateString(item.created)
        
        // Загрузка изображения с авторизацией
        if let originalSize = item.preview,
           let url = URL(string: originalSize) {
//            let headers: HTTPHeaders = [
//                "Authorization": "y0_AgAAAAAkCDffAAuG_gAAAAEAIT3BAADR8oAHnTZF4aBhf7m57hD2wqFbPQ"
//            ]
            miniImage.af.setImage(
                withURL: url,
                placeholderImage: UIImage(systemName: "photo.on.rectangle.angled"),
                filter: nil,
                progress: nil,
                progressQueue: DispatchQueue.main,
                imageTransition: .crossDissolve(0.2),
                runImageTransitionIfCached: false,
                completion: { response in
                    switch response.result {
                    case .success(let image):
                        self.miniImage.image = image
                    case .failure(let error):
                        if let response = response.response, response.statusCode == 403 {
                            self.miniImage.image = UIImage(systemName: "photo.on.rectangle.angled")
                            print("ты лох",error)
                        } else {
                            // Обрабатываем другие ошибки, если необходимо
                            print(error)
                        }
                    }
                }
            )
        } else {
            miniImage.image = UIImage(systemName: "photo.on.rectangle.angled")
        }

    }

    private func formatFileSize(_ size: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }

    private func formatDateString(_ date: String) -> String {
        // Форматирование строки даты, если формат даты известен
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let dateObj = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = "yyyy-MM-dd" // Измените на нужный формат
            return dateFormatter.string(from: dateObj)
        }
        return date
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
