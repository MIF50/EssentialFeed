//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 30/08/2022.
//

import Foundation

public struct ResourceErrorViewModel {
    public let message: String?
    
    static var noError: ResourceErrorViewModel {
        ResourceErrorViewModel(message: nil)
    }
    
    static func error(messsage: String) -> ResourceErrorViewModel {
        ResourceErrorViewModel(message: messsage)
    }
}
