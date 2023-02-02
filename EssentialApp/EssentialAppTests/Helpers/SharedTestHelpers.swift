//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Mohamed Ibrahim on 16/09/2022.
//

import Foundation
import EssentialFeed

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func uniqueFeed() -> [FeedImage] {
    [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
}

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
