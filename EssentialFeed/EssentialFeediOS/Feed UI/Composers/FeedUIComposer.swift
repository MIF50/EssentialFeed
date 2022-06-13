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
        let feedRefreshControl = FeedRefreshViewController(feedLoader: feedLoader)
        let feedController = FeedViewController(feedRefreshControl: feedRefreshControl)
        feedRefreshControl.onRefresh = { [weak feedController] feed in
            feedController?.tableModel = feed.map {  model in
                FeedImageCellController(model: model, imageLoader: imageLoader)
            }
        }
        return feedController
    }
}
