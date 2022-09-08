//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 07/09/2022.
//

import Foundation

public class RemoteFeedImageDataLoader: FeedImageDataLoader {
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func loadImageData(from url: URL,completion: @escaping((FeedImageDataLoader.Result) -> Void)) -> FeedImageDataLoaderTask {
        let task = HTTPTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError{ _ in Error.connectivity }
                .flatMap{ data,response in
                    let isValidResponse = response.statusCode == 200 && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                }
            )
        }
        return task
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private final class HTTPTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        var wrapped: HTTPClientTask?
        
        init(_ completion:@escaping ((FeedImageDataLoader.Result) -> Void)) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFutherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFutherCompletions() {
            completion = nil
        }
    }
}
