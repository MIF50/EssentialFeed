//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 25/06/2022.
//

import EssentialFeed

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    
    static var title: String {
        "My Feed"
    }
    
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    
    init(feedView: FeedView,loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed:  [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
       loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
