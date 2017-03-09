//
//  RedditClientTests.swift
//  Ring_TestTests
//
//  Created by Christopher Truman on 3/4/17.
//  Copyright © 2017 Christopher Truman. All rights reserved.
//

import XCTest
@testable import Ring_Test

class RedditClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFeed() {
        let exp = expectation(description: "Reddit Top")
        RedditClient.shared.feed(type: .top, completion: { posts in
            RedditClient.shared.comments(permalink: posts.first!.permalink, completion: { comments in
                exp.fulfill()
            })
        })
        waitForExpectations(timeout: 5)
    }
    
    func testParse() {
        let path = Bundle(for: type(of: self)).path(forResource: "new", ofType: "json")
        let data: NSData? = NSData(contentsOfFile: path!)
        let mediaItems = RedditClient.shared.parseResponse(data: data as! Data)
        XCTAssert(mediaItems.count == 25)
        XCTAssert(mediaItems.first?.URL != "")
    }
    
}
