//
//  FeedViewControllerTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Mohamed Ibrahim on 25/08/2022.
//

import Foundation
import XCTest
import EssentialFeed

extension FeedUIIntegrationTests {
    
    var commentsTitle: String {
        ImageCommentsPresenter.title
    }
    
    var feedTitle: String {
        FeedPresenter.title
    }
    
    var loadError: String {
        LoadResourcePresenter<Any,DummyView>.loadError
    }
    
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
}
