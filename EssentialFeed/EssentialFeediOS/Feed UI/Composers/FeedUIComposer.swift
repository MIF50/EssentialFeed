//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 13/06/2022.
//

import EssentialFeed

public final class FeedUIComposer {
    private init() { }
    
    public static func feedComposeWith(feedLoader: FeedLoader,imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let feedRefreshControl = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(feedRefreshControl: feedRefreshControl)
        feedViewModel.onLoadFeed = adaptFeedToCellControllers(forwarding: feedController, loader: imageLoader)
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwarding controller: FeedViewController,loader: FeedImageDataLoader) -> (([FeedImage]) -> Void) {
        return { [weak controller] feed in
            controller?.tableModel = feed.map {  model in
                FeedImageCellController(model: model, imageLoader: loader)
            }
        }
    }
}
