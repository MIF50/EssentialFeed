//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Mohamed Ibrahim on 13/12/2022.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

public final class CommentsUIComposer {
    private init() { }
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage],FeedViewAdapter>
    
    public static func commentsComposedWith(
        commentLoader: @escaping (() -> AnyPublisher<[FeedImage],Error>)
    ) -> ListViewController {
        let presentationAdapter = FeedPresentationAdapter(loader: commentLoader )
        let feedController = makeFeedViewController(title: ImageCommentsPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource
        let feedView = FeedViewAdapter(controller: feedController,imageLoader: { _ in Empty<Data,Error>().eraseToAnyPublisher() })
        
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
