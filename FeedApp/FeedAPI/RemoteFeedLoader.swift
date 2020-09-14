//
//  RemoteFeedLoader.swift
//  FeedApp
//
//  Created by Martynas Narijauskas on 2020-09-13.
//  Copyright © 2020 Martynas Narijauskas. All rights reserved.
//

import Foundation


public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func getData(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load (completion: @escaping (Result) -> Void) {
        client.getData(
            from: URL(string: "www.google.com")!,
            completion: { result in
                switch result {
                case .success(let data, let response):
                    if let items = try? FeedItemsMapper.map(data: data, response: response) {
                        completion(.success(items))
                    } else {
                        completion(.failure(.invalidData))
                    }
                case .failure:
                    completion(.failure(.connectivity))
                }
            }
        )
    }
}

private class FeedItemsMapper {
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(
                id: id,
                description: description,
                location: location,
                imageURL: image
            )
        }
    }

    private struct Items: Decodable {
        let items: [Item]
    }
    
    static var OK_200 = 200
    
    static func map(data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return try JSONDecoder().decode(Items.self, from: data).items.map { $0.item }
    }
}
