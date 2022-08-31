//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 12/06/2022.
//

import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellController: FeedImageView {
    
    private let delagete: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?

    init (delegate: FeedImageCellControllerDelegate) {
        self.delagete = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delagete.didRequestImage()
        return cell!
    }
    
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        
        cell?.feedImageView.setImageAnimated(viewModel.image)
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delagete.didRequestImage
    }
    
    func preload() {
        delagete.didRequestImage()
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        delagete.didCancelImageRequest()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}

