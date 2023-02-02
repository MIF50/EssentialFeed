//
//  ImageCommentsEndpoint.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 17/12/2022.
//

import Foundation

public enum ImageCommentsEndpoint {
    case get(UUID)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(id):
            return baseURL.appendingPathComponent("/v1/image/\(id)/comments")
        }
    }
}
