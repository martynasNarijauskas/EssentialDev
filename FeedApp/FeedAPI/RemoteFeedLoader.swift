//
//  RemoteFeedLoader.swift
//  FeedApp
//
//  Created by Martynas Narijauskas on 2020-09-13.
//  Copyright © 2020 Martynas Narijauskas. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load (completion: @escaping (Result) -> Void) {
        client.getData(
            from: URL(string: "www.google.com")!,
            completion: { [weak self] result in
                guard self != nil else {
                    return
                }
                
                switch result {
                case .success(let data, let response):
                    completion(FeedItemsMapper.map(data: data, response: response))
                case .failure:
                    completion(.failure(Error.connectivity))
                }
            }
        )
    }
}
