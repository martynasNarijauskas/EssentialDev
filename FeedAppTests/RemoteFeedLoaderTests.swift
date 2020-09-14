//
//  RemoteFeedLoaderTests.swift
//  FeedAppTests
//
//  Created by Martynas Narijauskas on 2020-09-01.
//  Copyright © 2020 Martynas Narijauskas. All rights reserved.
//

import XCTest
import FeedApp

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesnotRequestDataFromURL() {
        
       let (_, httpClient) = makeSUT()
        XCTAssertTrue(httpClient.requestedURLS.isEmpty)
    }
    
    func test_data_load() {
        let url = URL(string: "www.google.com")!
        let (sut, httpClient) = makeSUT(url: url)
        sut.load() { _ in }

        XCTAssertEqual(httpClient.requestedURLS, [url])
    }
    
    func test_data_loadTwice() {
        let url = URL(string: "www.google.com")!
        let(sut, httpClient) = makeSUT(url: url)
        sut.load() { _ in }
        sut.load() { _ in }

        XCTAssertEqual(httpClient.requestedURLS, [url, url])
    }
    
    func test_connection_error() {
        let (sut, httpClient) = makeSUT()
        
        expect(sut: sut, withResult: .failure(.connectivity), when: {
            let clientError = NSError(domain: "test", code: 0)
            httpClient.complete(with: clientError, index: 0)
        })
    }
    
    func test_invalid_data_error() {
        let (sut, httpClient) = makeSUT()
        let samples = [199, 201, 400, 500]
        
        samples.enumerated().forEach { index, code in
            
            expect(sut: sut, withResult: .failure(.invalidData), when: {
                let data = makeItemsJson([])
                httpClient.complete(with: code, data: data, index: index)
            })
        }
    }
    
    func test_response_200_invalid_json() {
        let (sut, httpClient) = makeSUT()
                    
        expect(sut: sut, withResult: .failure(.invalidData), when: {
            let invalidJson = Data("invalidJson".utf8)
            httpClient.complete(with: 200, data: invalidJson, index: 0)
        })
    }
    
    func test_response_200_empty_list() {
        let (sut, httpClient) = makeSUT()
        
        expect(sut: sut, withResult: .success([]), when: {
            let emptyListJson = makeItemsJson([])
            
            httpClient.complete(with: 200, data: emptyListJson, index: 0)
        })
    }
    
    
    func test_response_200_items_load() {
        let (sut, httpClient) = makeSUT()

        let item1 = makeItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageURL: URL(string: "http://a-url.com")!)

        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!)
        
        expect(sut: sut, withResult: .success([item1.model, item2.model]), when: {
            let json = makeItemsJson([item1.json, item2.json])
            httpClient.complete(with: 200, data: json, index: 0)
        })
    }

    
    private func makeSUT(url: URL = URL(string: "www.google.lt")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let httpClient = HTTPClientSpy()
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: httpClient)
        return (remoteFeedLoader, httpClient)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        
        let json = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.imageURL.absoluteString
        ].compactMapValues{ $0 }
        
        return (item, json)
    }
    
    private func makeItemsJson(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(sut: RemoteFeedLoader, withResult result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load() { capturedResults.append( $0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: (file), line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLS: [URL] {
            messages.map{ $0.url }
        }
                
        func getData(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, index: Int) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with statusCode: Int, data: Data, index: Int) {
            let response = HTTPURLResponse(
                url: messages[index].url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            
            messages[index].completion(.success(data, response))
        }
    }
}
