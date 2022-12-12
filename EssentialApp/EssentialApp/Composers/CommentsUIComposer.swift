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
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment],CommentsViewAdapter>
    
    public static func commentsComposedWith(
        commentLoader: @escaping (() -> AnyPublisher<[ImageComment],Error>)
    ) -> ListViewController {
        let presentationAdapter = FeedPresentationAdapter(loader: commentLoader )
        let feedController = makeFeedViewController(title: ImageCommentsPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource
        let feedView = CommentsViewAdapter(controller: feedController)
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resouceView: feedView,
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: { ImageCommentsPresenter.map($0) }
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

final class CommentsViewAdapter: ResourceView {
        
    private weak var controller: ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }
    
    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(
            viewModel.comments.map({ viewModel in
                CellController(id: viewModel, UITableViewController())
            })
        )
    }
}
