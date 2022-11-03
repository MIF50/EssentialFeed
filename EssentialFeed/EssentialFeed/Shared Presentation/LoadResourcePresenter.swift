//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 03/11/2022.
//

import Foundation

public protocol ResourceView {
    func display(_ viewModel: String)
}

public class LoadResourcePresenter {
    
    private var feedErrorMessage: String {
        NSLocalizedString(
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed when we can't load the image feed from the server"
        )
    }
    public typealias Mapper = (String) -> String
    
    private let resouceView: ResourceView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    private let mapper: Mapper

    public init(resouceView: ResourceView,loadingView: FeedLoadingView,errorView: FeedErrorView,mapper: @escaping Mapper) {
        self.resouceView = resouceView
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource: String) {
        resouceView.display(mapper(resource))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
        errorView.display(.error(messsage: feedErrorMessage))
    }
}
