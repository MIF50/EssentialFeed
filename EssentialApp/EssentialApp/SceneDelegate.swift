//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Mohamed Ibrahim on 13/09/2022.
//

import os
import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var logger = Logger(subsystem: "com.mif50.EssentailFeed", category: "main")
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        do {
            let localStoreURL = NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("feed-store.sqlite")
            return try CoreDataFeedStore(storeURL: localStoreURL)
        } catch {
            assertionFailure("Failed to instantiate CoreDataStore with error: \(error.localizedDescription)")
            logger.fault("Failed to instantiate CoreDataStore with error: \(error.localizedDescription)")
            return NullStore()
        }
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposeWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalImageLoaderWithRemoteFallback(for:),
            selection: showComments)
    )
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>,Error> {
        makeRemoteFeedLoader()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map(makeFirstPage)
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteLoadMoreLoader(last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>,Error> {
        localFeedLoader.loadPublisher()
            .zip(makeRemoteFeedLoader(after: last))
            .map { (cachedItems,newItems) in
                (cachedItems + newItems,newItems.last)
            }
            .map(makePage)
            .caching(to: localFeedLoader)
    }
    
    private func makeRemoteFeedLoader(after: FeedImage? = nil) -> AnyPublisher<[FeedImage],Error> {
        let url = FeedEndpoint.get(after: after).url(baseURL: baseURL)
        return httpClient
            .getPublisher(url: url)
            .tryMap(FeedItemsMapper.map)
            .eraseToAnyPublisher()
    }
    
    private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
        makePage(items: items, last: items.last)
    }
    
    private func makePage(items: [FeedImage],last: FeedImage?) -> Paginated<FeedImage> {
        Paginated(items: items,loadMorePublisher: last.map { last in
            { self.makeRemoteLoadMoreLoader(last: last) }
        })
    }
    
    private func showComments(for image: FeedImage) {
        let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
        let comments = CommentsUIComposer.commentsComposedWith(commentLoader: makeRemoteCommentsLoader(url: url))
        navigationController.pushViewController(comments, animated: true)
    }
    
    private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment],Error> {
        return { [httpClient] in
            return httpClient.getPublisher(url: url)
                .tryMap(ImageCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(for url: URL) -> FeedImageDataLoader.Publisher {
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .logCacheMisses(url: url,logger: logger)
            .fallback(to: { [httpClient,logger] in
                httpClient
                    .getPublisher(url: url)
                    .logElaspedTime(url: url, logger: logger)
                    .logErrors(url: url, logger: logger)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
            }).eraseToAnyPublisher()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
}

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
