//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 12/06/2022.
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
