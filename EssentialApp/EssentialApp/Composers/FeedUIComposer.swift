//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 13/06/2022.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
    private init() { }
    
    public static func feedComposeWith(
        feedLoader: @escaping (() -> FeedLoader.Publisher),
        imageLoader: FeedImageDataLoader
    ) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: { feedLoader().dispatchOnMainQueue() })
        
        let feedController = makeFeedViewController(delegate: presentationAdapter, title: FeedPresenter.title)
        
        let feedView = FeedViewAdapter(
            controller: feedController,
            imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)
        )
        
        presentationAdapter.presenter = FeedPresenter(
            feedView: feedView,
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController)
        )
        return feedController
    }
    
    private static func makeFeedViewController(delegate: FeedViewControllerDelegate,title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}

