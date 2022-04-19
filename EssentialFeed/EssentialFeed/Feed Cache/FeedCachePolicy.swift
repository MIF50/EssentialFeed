//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 28/03/2022.
//

import Foundation

final class FeedCachePolicy {
    
    private init() {}
    
    private static let calendar = Calendar(identifier: .gregorian)
    
    private static var maxCacheAgaInDays: Int {
        return 7
    }
    
    static func validate(_ timestamp: Date,against date: Date)-> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgaInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
