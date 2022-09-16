//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Mohamed Ibrahim on 13/09/2022.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        
        let httpClient: HTTPClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let localFeedStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite")
        let store = try! CoreDataFeedStore(storeURL: localFeedStoreURL)
        let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
        let localImageDataLoader = LocalFeedImageDataLoader(store: store)
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: httpClient)
        let remoteImageDataLoader = RemoteFeedImageDataLoader(client: httpClient)
        let feedLoader = FeedLoaderWithFallbackComposite(primary: remoteFeedLoader, fallback: localFeedLoader)
        let imageLoader = FeedImageDataLoaderWithFallbackComposite(primary: localImageDataLoader, fallback: remoteImageDataLoader)
        let feedViewController = FeedUIComposer.feedComposeWith(feedLoader: feedLoader,imageLoader: imageLoader)
        window?.rootViewController = feedViewController
        window?.makeKeyAndVisible()
    }

}

