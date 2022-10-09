//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 08/10/2022.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(url: URL,client: HTTPClient) {
        self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
    }
}
