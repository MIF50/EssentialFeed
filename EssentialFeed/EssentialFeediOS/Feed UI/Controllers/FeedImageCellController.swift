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

public final class FeedImageCellController: ResourceView, ResourceLoadingView,ResourceErrorView {
    public typealias ResouceViewModel = UIImage
    
    private let viewModel: FeedImageViewModel
    private let delagete: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?

    public init (viewModel: FeedImageViewModel,delegate: FeedImageCellControllerDelegate) {
        self.viewModel = viewModel
        self.delagete = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        
        cell?.onRetry = delagete.didRequestImage
        delagete.didRequestImage()
        return cell!
    }
    
    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setImageAnimated(viewModel)
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.feedImageRetryButton.isHidden = viewModel.message == nil
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

