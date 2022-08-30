//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 30/08/2022.
//

import Foundation

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: nil)
    }
    
    static func error(messsage: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: messsage)
    }
}
