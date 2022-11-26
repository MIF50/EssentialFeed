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

public final class FeedImageCellController: CellController, ResourceView, ResourceLoadingView,ResourceErrorView {
    public typealias ResouceViewModel = UIImage
    
    private let viewModel: FeedImageViewModel
    private let delagete: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?

    public init (viewModel: FeedImageViewModel,delegate: FeedImageCellControllerDelegate) {
        self.viewModel = viewModel
        self.delagete = delegate
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        
        cell?.onRetry = delagete.didRequestImage
        delagete.didRequestImage()
        return cell!
    }
    
    public func preload() {
        delagete.didRequestImage()
    }
    
    public func cancelLoad() {
        releaseCellForReuse()
        delagete.didCancelImageRequest()
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
    
    private func releaseCellForReuse() {
        cell = nil
    }
}

