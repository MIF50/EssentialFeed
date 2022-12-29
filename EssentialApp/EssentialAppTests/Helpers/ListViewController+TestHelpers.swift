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
    
    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }
    
    func cell(row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

extension ListViewController {
    
    func commentMessage(at row: Int) -> String? {
        commentView(at: row)?.messageLabel.text
    }
    
    func commentDate(at row: Int) -> String? {
        commentView(at: row)?.dateLabel.text
    }
    
    func commentUsername(at row: Int) -> String? {
        commentView(at: row)?.usernameLabel.text
    }
    
    private func commentView(at row: Int)-> ImageCommentCell? {
        cell(row: row, section: commentsSection) as? ImageCommentCell
    }
    
    func numberOfRenderedComments()-> Int {
        numberOfRows(in: commentsSection)
    }
    
    private var commentsSection: Int { 0 }
}

extension ListViewController {
    
    func simulateTapOnFeedImage(at row: Int) {
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
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
    
    func simulateLoadMoreFeedAction() {
        guard let view = loadMoreFeedCell() else { return }
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: 0, section: feedLoadMoreSection)
        delegate?.tableView?(tableView, willDisplay: view, forRowAt: indexPath)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        cell(row: row, section: feedImagesSection)
    }
    
    var isShowingLoadingMoreIndicator: Bool {
        loadMoreFeedCell()?.isLoading == true
    }
    
    private func loadMoreFeedCell() -> LoadMoreCell? {
        cell(row: 0, section: feedLoadMoreSection) as? LoadMoreCell
    }
    
    func numberOfRenderedFeedImageViews()-> Int {
        numberOfRows(in: feedImagesSection)
    }
    
    private var feedImagesSection: Int { 0 }
    private var feedLoadMoreSection: Int { 1 }

}
