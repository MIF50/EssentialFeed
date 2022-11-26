//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 13/06/2022.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

public final class FeedUIComposer {
    private init() { }
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage],FeedViewAdapter>
    
    public static func feedComposeWith(
        feedLoader: @escaping (() -> AnyPublisher<[FeedImage],Error>),
        imageLoader: @escaping ((URL) -> FeedImageDataLoader.Publisher)
    ) -> ListViewController {
        let presentationAdapter = FeedPresentationAdapter(loader: feedLoader)
        let feedController = makeFeedViewController(title: FeedPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource
        let feedView = FeedViewAdapter(controller: feedController,imageLoader: imageLoader)
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resouceView: feedView,
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map
        )
        return feedController
    }
    
    private static func makeFeedViewController(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
}

