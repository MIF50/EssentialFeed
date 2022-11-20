//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 03/11/2022.
//

import Foundation

public protocol ResourceView {
    associatedtype ResouceViewModel
    func display(_ viewModel: ResouceViewModel)
}

public class LoadResourcePresenter<Resource,View: ResourceView> {
    
    public static var loadError: String {
        NSLocalizedString(
            "GENERIC_CONNECTION_ERROR",
            tableName: "Shared",
            bundle: Bundle(for: Self.self),
            comment: "Error message displayed when we can't load resource from the server"
        )
    }
    
    public typealias Mapper = (Resource) -> View.ResouceViewModel
    
    private let resouceView: View
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    private let mapper: Mapper

    public init(resouceView: View,loadingView: FeedLoadingView,errorView: FeedErrorView,mapper: @escaping Mapper) {
        self.resouceView = resouceView
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource: Resource) {
        resouceView.display(mapper(resource))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
        errorView.display(.error(messsage: Self.loadError))
    }
}
