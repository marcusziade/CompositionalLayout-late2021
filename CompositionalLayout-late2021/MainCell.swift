//
//  MainCell.swift
//  CompositionalLayout-late2021
//
//  Created by Marcus Ziadé on 6.11.2021.
//

import UIKit

final class MainCell: UICollectionViewCell {
    
    func configure(with number: Int) {
        titleLabel.text = String(number)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [imageView, titleLabel]).forAutoLayout()
        view.axis = .horizontal
        view.alignment = .leading
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "person.fill"))
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
}
