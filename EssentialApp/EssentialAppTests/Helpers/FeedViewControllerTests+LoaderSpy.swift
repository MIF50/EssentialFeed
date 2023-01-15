//
//  FeedViewControllerTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Mohamed Ibrahim on 12/06/2022.
//

import UIKit
import Combine
import EssentialFeediOS
import EssentialFeed

class LoaderSpy: FeedImageDataLoader {
   
    // MARK: - FeedLoader
    
    private var feedRequests = [((PassthroughSubject<Paginated<FeedImage>,Error>))]()
    private var loadMoreRequests = [((PassthroughSubject<Paginated<FeedImage>,Error>))]()

    var loadFeedCallCount: Int { feedRequests.count }
    
    var loadMoreCallCount: Int { loadMoreRequests.count }

    
    func loadPublisher() -> AnyPublisher<Paginated<FeedImage>,Error> {
        let publisher = PassthroughSubject<Paginated<FeedImage>,Error>()
        feedRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }
    
    func completeFeedLoading(with feed: [FeedImage] = [],at index: Int) {
        feedRequests[index].send(Paginated(items: feed,loadMorePublisher: { [weak self] in
            let publisher = PassthroughSubject<Paginated<FeedImage>,Error>()
            self?.loadMoreRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }))
        feedRequests[index].send(completion: .finished)
    }
    
    func completeFeedLoadingWithError(at index: Int) {
        let error = NSError(domain: "any error", code: 0)
        feedRequests[index].send(completion: .failure(error))
    }
    
    // LoadMore
    
    func completeLoadMore(with feed: [FeedImage] = [],lastPage: Bool = false,at index: Int) {
        loadMoreRequests[index].send(Paginated(
            items: feed,
            loadMorePublisher: lastPage ? nil : { [weak self] in
                let publisher = PassthroughSubject<Paginated<FeedImage>,Error>()
                self?.loadMoreRequests.append(publisher)
                return publisher.eraseToAnyPublisher()
            }))
    }
    
    func completeLoadMoreWithError(at index: Int) {
        let error = NSError(domain: "any error", code: 0)
        loadMoreRequests[index].send(completion: .failure(error))
    }
    
    // MARK: - FeedImageDataLoader
    
    private var imageRequests = [(url: URL,completion: ((FeedImageDataLoader.Result) -> Void))]()
    
    private struct TaskSpy: FeedImageDataLoaderTask {
        let cancelCallback: (() -> Void)
        
        func cancel() {
            cancelCallback()
        }
    }
    
    var loadedImageURLs: [URL] {
        imageRequests.map { $0.url }
    }
    
    private(set) var cancelledImageURLs = [URL]()
    
    func loadImageData(
        from url: URL,
        completion: @escaping ((FeedImageDataLoader.Result) -> Void)
    ) -> FeedImageDataLoaderTask {
        imageRequests.append((url,completion))
        return TaskSpy { [weak self] in
            self?.cancelledImageURLs.append(url)
        }
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int) {
        imageRequests[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError(at index: Int) {
        let error = NSError(domain: "any error", code: 0)
        imageRequests[index].completion(.failure(error))
    }
}
