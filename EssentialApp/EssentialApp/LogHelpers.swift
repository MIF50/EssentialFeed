//
//  LogHelpers.swift
//  EssentialApp
//
//  Created by Mohamed Ibrahim on 24/01/2023.
//

import Foundation
import UIKit
import EssentialFeed
import os
import Combine

extension Publisher {
    
    func logCacheMisses(url: URL,logger: Logger) -> AnyPublisher<Output,Failure> {
        handleEvents(receiveCompletion: { result in
            if case .failure = result {
                logger.trace("Cache miss for url: \(url)")
            }
        }).eraseToAnyPublisher()
    }
    
    func logErrors(url: URL,logger: Logger) -> AnyPublisher<Output,Failure> {
        handleEvents(receiveCompletion: { result in
            if case let .failure(error) = result {
                logger.trace("Failed to load url: \(url) with error: \(error)")
            }
        }).eraseToAnyPublisher()
    }
    
    func logElaspedTime(url: URL,logger: Logger) -> AnyPublisher<Output,Failure> {
        var startTime = CACurrentMediaTime()

        return handleEvents(receiveSubscription: { _ in
            logger.trace("start loading url: \(url)")
            startTime = CACurrentMediaTime()
        },receiveCompletion: { _ in
            let elapsed = CACurrentMediaTime() - startTime
            logger.trace("finish loading url: \(url) in \(elapsed) seconds")
        }).eraseToAnyPublisher()
    }
}

private class HTTPClientProfilingDecorator: HTTPClient {
    
    private let deocratee: HTTPClient
    private let logger: Logger
    
    internal init(deocratee: HTTPClient, logger: Logger) {
        self.deocratee = deocratee
        self.logger = logger
    }
    
    func get(from url: URL, completion: @escaping ((HTTPClient.Result) -> Void)) -> HTTPClientTask {
        logger.trace("start loading url: \(url)")
        let startTime = CACurrentMediaTime()
        
        return deocratee.get(from: url) {  [logger] result in
            if case let .failure(error) = result {
                logger.trace("Failed to load url: \(url) with error: \(error)")
            }
            
            let elapsed = CACurrentMediaTime() - startTime
            logger.trace("finish loading url: \(url) in \(elapsed) seconds")
            completion(result)
        }
    }
}
