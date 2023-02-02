//
//  FeedImageCell+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Mohamed Ibrahim on 12/06/2022.
//

import UIKit
import EssentialFeediOS

extension FeedImageCell {
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }
    
    var isShowingRetryAction: Bool {
        !feedImageRetryButton.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        feedImageContainer.isShimmering
    }
    
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }
}
