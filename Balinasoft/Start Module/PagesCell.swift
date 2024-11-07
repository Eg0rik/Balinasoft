//
//  PagesCell.swift
//  Balinasoft
//
//  Created by MAC on 11/6/24.
//

import UIKit

class PagesCell: UITableViewCell {
    
    //MARK: - Public properties
    static let identifier = "PagesCell"
    
    //MARK: - Private properties
    
    ///Insets for content in the `contentView`.
    private let contentViewInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
    
    //MARK: - Views
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "-1"
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        return indicator
    }()
    
    private lazy var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.addSubview(indicatorView)
        return imageView
    }()
    
    //MARK: - Life cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - public methods
    func configure(rowContent: RowContent, imageLoader: ImageLoader) {
        
        label.text = "\(rowContent.id) - \(rowContent.name)"
        
        guard let url = rowContent.imageURL else {
            setImagePlaceholder()
            return
        }
        
        imageLoader.loadImage(url: url) { [weak self] image in
            guard let image else {
                self?.setImagePlaceholder()
                return
            }
            
            self?.leftImageView.image = image
            self?.stopShowingIndicator()
        }
    }
    
    override func prepareForReuse() {
        indicatorView.isHidden = false
        indicatorView.startAnimating()
    }
}

//MARK: - Private methods
private extension PagesCell {
    func setupView() {
        contentView.addSubviews(leftImageView, label)
        accessoryView = UIImageView(image: UIImage(systemName: "arrow.right"))
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            leftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentViewInsets.left),
            leftImageView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -10),
            leftImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentViewInsets.top),
            leftImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentViewInsets.bottom).lowPriority,
            leftImageView.heightAnchor.constraint(equalToConstant: 120),
            leftImageView.widthAnchor.constraint(equalToConstant: 120),
            
            label.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -contentViewInsets.right),
            label.topAnchor.constraint(equalTo: leftImageView.topAnchor),
            label.bottomAnchor.constraint(equalTo: leftImageView.bottomAnchor),
            
            indicatorView.leadingAnchor.constraint(equalTo: leftImageView.leadingAnchor),
            indicatorView.topAnchor.constraint(equalTo: leftImageView.topAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: leftImageView.bottomAnchor),
            indicatorView.trailingAnchor.constraint(equalTo: leftImageView.trailingAnchor),
        ])
    }
    
    func setImagePlaceholder() {
        leftImageView.image = UIImage(systemName: "nosign")
        stopShowingIndicator()
    }
    
    func stopShowingIndicator() {
        indicatorView.isHidden = true
        indicatorView.stopAnimating()
    }
}

#Preview {
    StartViewController(viewModel: .init())
}
