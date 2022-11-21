//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 27/08/2022.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class LoadResourcePresentationAdapter<Resource,View: ResourceView> {
    
    private let loader: (() -> AnyPublisher<Resource,Error>)
    var presenter: LoadResourcePresenter<Resource,View>?
    private var cancellable: Cancellable?
    
    init(loader: @escaping(() -> AnyPublisher<Resource,Error>)) {
        self.loader = loader
    }
    
    func loadResource() {
        presenter?.didStartLoading()
        
        cancellable = loader()
            .dispatchOnMainQueue()
            .sink { [weak self] completion in
            switch completion {
            case .finished: break
                
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
        } receiveValue: { [weak self] feed in
            self?.presenter?.didFinishLoading(with: feed)
        }
    }
}

extension LoadResourcePresentationAdapter: FeedViewControllerDelegate {
    func didRequestFeedRefresh() {
        loadResource()
    }
}
