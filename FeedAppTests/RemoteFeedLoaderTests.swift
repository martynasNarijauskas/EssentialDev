//
//  RemoteFeedLoaderTests.swift
//  FeedAppTests
//
//  Created by Martynas Narijauskas on 2020-09-01.
//  Copyright © 2020 Martynas Narijauskas. All rights reserved.
//

import XCTest
@testable import FeedApp

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesnotRequestDataFromURL() {
        
       let (_, httpClient) = makeSUT()
        XCTAssertTrue(httpClient.requestedURLS.isEmpty)
    }
    
    func test_data_load() {
        let url = URL(string: "www.google.com")!
        let(sut, httpClient) = makeSUT(url: url)
        sut.load()

        XCTAssertEqual(httpClient.requestedURLS, [url])
    }
    
    func test_data_loadTwice() {
        let url = URL(string: "www.google.com")!
        let(sut, httpClient) = makeSUT(url: url)
        sut.load()
        sut.load()

        XCTAssertEqual(httpClient.requestedURLS, [url, url])
    }
    
    private func makeSUT(url: URL = URL(string: "www.google.lt")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let httpClient = HTTPClientSpy()
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: httpClient)
        return (remoteFeedLoader, httpClient)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLS = [URL]()

        func load(from url: URL) {
            requestedURLS.append(url)
        }
    }
}
