//
//  URLSessionHTTPClientTest.swift
//  FeedAppTests
//
//  Created by Martynas Narijauskas on 2020-09-19.
//  Copyright © 2020 Martynas Narijauskas. All rights reserved.
//

import XCTest
import FeedApp


class URLSessionHttpClient {
    let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func get(from url: URL, completionHandler: @escaping (HTTPClientResult) -> Void) {
        urlSession.dataTask(with: url) { (_, _, error) in
            if let error = error {
                completionHandler(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTest: XCTestCase {
    
    func test_error() {
        let nsError = NSError(domain: "Random error", code: 1)
        let error = nsError as Error
        
        XCTAssertEqual(nsError, error as NSError)
    }
    
    func test_error_fromDataTask() {
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "www.google.com")!
        let error = NSError(domain: "Random error", code: 1)
        URLProtocolStub.stub(url: url, error: error)
                
        let sut = URLSessionHttpClient()
        
        let exp = expectation(description: "Wait for data task")
        
        sut.get(from: url) { result in
            switch result {
            case .failure(let receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
            default:
                XCTFail("Got result instead of error")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequests()
    }
    
    // MARK: Helpers
    private class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let error: Error?
        }
        
        static func stub(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(self)
            stubs = [:]
        }
        
        override func stopLoading() {}
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else {
                return
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else {
                return false
            }
            
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
    }
    
//    private class MockURLsessionDataTask: URLSessionDataTask {
//
//        override func resume() {
//
//        }
//    }
    

}
