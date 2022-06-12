//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 04/05/2022.
//

import UIKit

final public class FeedImageCell: UITableViewCell {
    
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    public private(set) lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
     @objc private func retryButtonTapped() {
        onRetry?()
    }
}
