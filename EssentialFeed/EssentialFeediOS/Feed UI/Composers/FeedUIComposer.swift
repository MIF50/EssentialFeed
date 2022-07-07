//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 13/06/2022.
//

import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() { }
    
    public static func feedComposeWith(feedLoader: FeedLoader,imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presenter = FeedPresenter(feedLoader: feedLoader)
        let feedRefreshControl = FeedRefreshViewController(presenter: presenter)
        let feedController = FeedViewController(feedRefreshControl: feedRefreshControl)
        presenter.loadingView = feedRefreshControl
        let feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)
        presenter.feedView = feedView
        return feedController
    }
}

final class FeedViewAdapter: FeedView {
    
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController,imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(feed: [FeedImage]) {
        controller?.tableModel = feed.map {  model in
            FeedImageCellController(
                viewModel: FeedImageViewModel(model: model,
                                             imageLoader: imageLoader,
                                             imageTransformer: UIImage.init)
            )
        }
    }
    
}
