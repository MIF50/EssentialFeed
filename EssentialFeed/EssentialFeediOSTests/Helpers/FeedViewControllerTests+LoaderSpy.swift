//
//  FeedViewControllerTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Mohamed Ibrahim on 12/06/2022.
//

import UIKit
import EssentialFeediOS
import EssentialFeed

class LoaderSpy: FeedLoader, FeedImageDataLoader {
   
    // MARK: - FeedLoader
    
    private var feedRequests = [((FeedLoader.Result) -> Void)]()
    
    var loadFeedCallCount: Int {
        feedRequests.count
    }
    
    func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
        feedRequests.append(completion)
    }
    
    func completeFeedLoading(with feed: [FeedImage] = [],at index: Int) {
        feedRequests[index](.success(feed))
    }
    
    func completeFeedLoadingWithError(at index: Int) {
        let error = NSError(domain: "any error", code: 0)
        feedRequests[index](.failure(error))
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
