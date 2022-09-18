//
//  FeedImageLoaderSpy.swift
//  EssentialAppTests
//
//  Created by Mohamed Ibrahim on 18/09/2022.
//

import Foundation
import EssentialFeed

final class FeedImageLoaderSpy: FeedImageDataLoader {
    
    private(set) var messages = [(url: URL,completion: (FeedImageDataLoader.Result) -> Void)]()
    
    var loadedURLs: [URL] {
        messages.map { $0.url }
    }
    
    private(set) var cancelledURLs = [URL]()
    
    func loadImageData(from url: URL, completion: @escaping ((FeedImageDataLoader.Result) -> Void)) -> FeedImageDataLoaderTask {
        messages.append((url,completion))
        return Task{ [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    func complete(with data: Data,at index: Int = 0) {
        messages[index].completion(.success((data)))
    }
    
    func complete(with error: NSError,at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    private struct Task: FeedImageDataLoaderTask {
        var callback: (() -> Void)?
        
        func cancel() {
            callback?()
        }
    }
}
