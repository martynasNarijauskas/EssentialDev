//
//  HTTPClient.swift
//  FeedApp
//
//  Created by Martynas Narijauskas on 2020-09-14.
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
