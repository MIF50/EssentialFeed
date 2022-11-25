//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 27/08/2022.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceView {
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data,WeakRefVirtualProxy<FeedImageCellController>>
    
    private weak var controller: FeedViewController?
    private let imageLoader: ((URL) -> FeedImageDataLoader.Publisher)
    
    init(controller: FeedViewController,imageLoader: @escaping ((URL) -> FeedImageDataLoader.Publisher)) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map {  model in
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
                imageLoader(model.url)
            })

            let view = FeedImageCellController(viewModel: FeedImagePresenter.map(model),delegate: adapter)
            
            adapter.presenter = LoadResourcePresenter(
                resouceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: UIImage.tryMake)
            
            return view
        })
    }
}

private extension UIImage {
    
    private struct InvalidImageData: Error {}
    
    static func tryMake(_ data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        
        return image
    }
}
