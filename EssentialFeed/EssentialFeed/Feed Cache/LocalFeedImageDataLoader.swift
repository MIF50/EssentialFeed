//
//  LocalFeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 10/09/2022.
//

import Foundation

public final class LocalFeedImageDataLoader {
    
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    public typealias SaveResult = FeedImageDataCache.Result
    
    public func save(_ data: Data,for url: URL,completion: @escaping ((SaveResult) -> Void)) {
        completion(SaveResult{
            try store.insert(data: data, for: url)
        }.mapError { _ in SaveError.failed })
    }
    
    public enum SaveError: Error {
        case failed
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    
    public typealias LoadResult = FeedImageDataLoader.Result
    
    public func loadImageData(from url: URL, completion: @escaping ((FeedImageDataLoader.Result) -> Void)) -> FeedImageDataLoaderTask {
        let task = Task(completion)
        task.complete(with: Swift.Result {
            try store.retrieve(dataForURL: url)
        }
            .mapError{ _ in LoadError.failed }
            .flatMap { data in data.map { .success($0) } ?? .failure(LoadError.notFound) }
        )
        return task
    }
    
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    private final class Task: FeedImageDataLoaderTask {
        
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion:@escaping ((FeedImageDataLoader.Result) -> Void)) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFutherCompletions()
        }
        
        func preventFutherCompletions() {
            completion = nil
        }
    }
}
