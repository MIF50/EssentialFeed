//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Mohamed Ibrahim on 12/06/2022.
//

import UIKit
import EssentialFeediOS

extension ListViewController {
    
    public override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        
        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    var errorMessage: String? {
        errorView.message
    }
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
    }
    
    func simulateUserInitiatedReload() {
        self.refreshControl?.simulatePullToRefresh()
    }
}

extension ListViewController {
    
    func numberOfRenderedComments()-> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: commentsSection)
    }
    
    private var commentsSection: Int { 0 }
}

extension ListViewController {
    
    @discardableResult
    func simulateFeedImageViewVisible(at row: Int)-> FeedImageCell? {
        return feedImageView(at: row) as? FeedImageCell
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        return view
    }
    
    func feedImageView(at row: Int)-> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    func numberOfRenderedFeedImageViews()-> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    private var feedImagesSection: Int { 0 }
}
