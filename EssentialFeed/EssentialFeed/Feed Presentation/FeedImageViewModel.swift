//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 31/08/2022.
//

import Foundation

public struct FeedImageViewModel {
    
    public let description: String?
    public let location: String?
  
    public var hasLocation: Bool {
        location != nil
    }
}
