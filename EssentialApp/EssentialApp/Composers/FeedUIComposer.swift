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
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>,FeedViewAdapter>
    
    public static func feedComposeWith(
        feedLoader: @escaping (() -> AnyPublisher<Paginated<FeedImage>,Error>),
        imageLoader: @escaping ((URL) -> FeedImageDataLoader.Publisher),
        selection: @escaping ((FeedImage) -> Void)
    ) -> ListViewController {
        let presentationAdapter = FeedPresentationAdapter(loader: feedLoader)
        let feedController = makeFeedViewController(title: FeedPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource
        let feedView = FeedViewAdapter(controller: feedController,imageLoader: imageLoader,selection: selection)
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: feedView,
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: { $0 }
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

