//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 18/06/2022.
//

import Foundation

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}
