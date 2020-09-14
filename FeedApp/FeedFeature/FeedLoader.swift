//
//  File.swift
//  FeedApp
//
//  Created by Martynas Narijauskas on 2020-09-01.
//  Copyright © 2020 Martynas Narijauskas. All rights reserved.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
