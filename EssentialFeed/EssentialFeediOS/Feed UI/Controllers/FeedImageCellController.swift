//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 12/06/2022.
//

import UIKit

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellController: FeedImageView {
    
    private let delagete: FeedImageCellControllerDelegate
    private lazy var cell = FeedImageCell()

    init (delegate: FeedImageCellControllerDelegate) {
        self.delagete = delegate
    }
    
    func view() -> UITableViewCell {
        delagete.didRequestImage()
        return cell
    }
    
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        
        cell.feedImageView.image = viewModel.image
        cell.feedImageContainer.isShimmering = viewModel.isLoading
        cell.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell.onRetry = delagete.didRequestImage
    }
    
    func preload() {
        delagete.didRequestImage()
    }
    
    func cancelLoad() {
        delagete.didCancelImageRequest()
    }
}

