//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 03/04/2022.
//

import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
    
    var local: LocalFeedImage {
        LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
}

extension ManagedFeedImage {
    
    static func image(from feed: [LocalFeedImage],in context: NSManagedObjectContext) -> NSOrderedSet{
        NSOrderedSet(array: feed.map({ local in
            let managed = ManagedFeedImage(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.url = local.url
            return managed
        }))
    }
}
