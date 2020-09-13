//
//  RemoteFeedLoader.swift
//  FeedApp
//
//  Created by Martynas Narijauskas on 2020-09-13.
//  Copyright © 2020 Martynas Narijauskas. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    func load(from url: URL)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    public func load () {
        client.load(from: URL(string: "www.google.com")!)
    }
}
