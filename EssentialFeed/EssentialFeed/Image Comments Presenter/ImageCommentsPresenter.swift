//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 25/11/2022.
//

import Foundation

public final class ImageCommentsPresenter {
    
    public static var title: String {
        NSLocalizedString(
            "IMAGE_COMMENTS_VIEW_TITLE",
            tableName: "ImageComments",
            bundle: Bundle(for: Self.self),
            comment: "title for image comments view"
        )
    }
}
