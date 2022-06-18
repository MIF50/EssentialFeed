//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 18/06/2022.
//

import UIKit
import EssentialFeed

final class FeedImageViewModel {
    typealias Observer<T> = (T) -> Void
    
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    init (model: FeedImage,imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    var hasLocation: Bool {
        model.location != nil
    }
    
    var location: String? {
        model.location
    }
    
    var description: String? {
        model.description
    }
    
    var onImageLoad: Observer<UIImage>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadingStateChange: Observer<Bool>?
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadingStateChange?(false)
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: Result<Data,Error>) {
        if let image = (try? result.get()).flatMap(UIImage.init) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadingStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }
    
    func cancelImageLoad() {
        task?.cancel()
        task = nil
    }
}
