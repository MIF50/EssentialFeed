//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Mohamed Ibrahim on 03/05/2022.
//

import XCTest
import EssentialFeediOS
import EssentialFeed

final class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestsFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completes successfully")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completes with error")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description",location: "a location")
        let image1 = makeImage(description: "a description",location: nil)
        let image2 = makeImage(description: nil,location: "a location")
        let image3 = makeImage(description: nil,location: nil)

        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0],at: 0)
        assertThat(sut, isRendering: [image0])

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0,image1,image2,image3], at: 1)
        assertThat(sut, isRendering: [image0,image1,image2,image3])
    }
    
    func test_loadFeedCompletion_doesNotAlertCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0,image1], at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [],"Expected no image URL requests until views become visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url],"Expected first image URL request once first view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url,image1.url],"Expected second image URL request once second view also becomes visible")
    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0,image1], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [],"Expected no cancelled image URL requests until image is not visible")
        
        sut.simulateFeedImageviewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url],"Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulateFeedImageviewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url,image1.url],"Expected two cancelled image URL requests once second image is also not visible anymore")
        
    }
    
    // MARK: - Helper
    
    private func makeSUT(file: StaticString = #filePath,line: UInt = #line)-> (sut: FeedViewController,loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader,imageLoader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut,loader)
    }
    
    private func assertThat(
        _ sut: FeedViewController,
        isRendering feed: [FeedImage],
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead.", file: file, line: line)
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfigureFor: image, at: index,file: file,line: line)
        }
    }
    
    private func assertThat(
        _ sut: FeedViewController,
        hasViewConfigureFor image: FeedImage,
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldLocationBeVisible = (image.location != nil)
        
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible,"Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index (\(index))", file: file, line: line)
        XCTAssertEqual(cell.locationText, image.location,"Expected location text to be \(String(describing: image.location)) for image view at index (\(index))", file: file, line: line)
        XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index (\(index)", file: file, line: line)
    }
    
    private func makeImage(
        description: String? = nil,
        location: String? = nil,
        url: URL = URL(string: "http://any-url.com")!
    )-> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
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
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallback: (() -> Void)
            
            func cancel() {
                cancelCallback()
            }
        }
        
        private(set) var loadedImageURLs = [URL]()
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL) -> FeedImageDataLoaderTask {
            loadedImageURLs.append(url)
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
    }
}

private extension FeedViewController {
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func simulateUserInitiatedFeedReload() {
        self.refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at row: Int)-> FeedImageCell? {
        return feedImageView(at: row) as? FeedImageCell
    }
    
    func simulateFeedImageviewNotVisible(at row: Int) {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    }
    
    func feedImageView(at row: Int)-> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    func numberOfRenderedFeedImageViews()-> Int {
        tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    private var feedImagesSection: Int { 0 }
}

private extension FeedImageCell {
    
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
}

private extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        self.allTargets.forEach { target in
            self.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
