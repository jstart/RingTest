//
//  InstagramClient.swift
//  Ring_Test
//
//  Created by Christopher Truman on 3/4/17.
//  Copyright © 2017 Christopher Truman. All rights reserved.
//

import Foundation

struct Post {
    var caption, permalink, URL, author: String
    var imageURL : String?
    var commentCount: Int
    var createdAt: Date
    
    static func parse(dict: NSDictionary) -> Post {
        let data = dict.object(forKey: "data") as? NSDictionary
        let caption = data?["title"] as? String ?? ""
        let permalink = data?["permalink"] as? String ?? ""
        let URL = data?["url"] as? String ?? ""
        let imageURL = data?["thumbnail"] as? String
        let author = data?["author"] as? String ?? ""
        let commentCount = data?["num_comments"] as? Int ?? 0
        let createdAt = Date(timeIntervalSince1970: (data?["created_utc"] as? Double)!)

        return Post(caption: caption, permalink: permalink, URL: URL, author: author, imageURL: imageURL, commentCount: commentCount, createdAt: createdAt)
    }
}

struct Comment {
    var body, author: String
    var replyCount: Int
    
    static func parse(dict: NSDictionary) -> Comment {
        let data = dict.object(forKey: "data") as? NSDictionary
        let body = data?["body"] as? String ?? ""
        let author = data?["author"] as? String ?? ""
        let replyCount = (((data?["replies"] as? NSDictionary)?["data"] as? NSDictionary)?["children"] as? NSArray)?.count ?? 0

        return Comment(body: body, author: author, replyCount: replyCount)
    }
}

enum FeedType : String {
    case hot = "hot", new = "new", top = "top"
}

class RedditClient {
    
    var moreAvailable = false
    
    var after : String?
    
    static let shared = RedditClient()
    
    func feed(type: FeedType, completion: @escaping ([Post]) -> Void) {
        let session = URLSession(configuration: .default)
        //http://www.reddit.com/r/all/new.json
        let url = URL(string: "http://www.reddit.com/r/all/\(type).json")!
        let task = session.dataTask(with: url) {
            data, response, error in
            guard let data = data else { completion([]); return }
            let posts = self.parseResponse(data: data)
            DispatchQueue.main.async {
                completion(posts)
            }
        }
           
        task.resume()
    }
    
    func nextFeed(type: FeedType, completion: @escaping ([Post]) -> Void) {
        let session = URLSession(configuration: .default)
        let url = URL(string: "http://www.reddit.com/r/all/\(type).json?after=\(after!)")!
        let task = session.dataTask(with: url) {
            data, response, error in
            guard let data = data else { completion([]); return }
            let mediaItems = self.parseResponse(data: data)
            DispatchQueue.main.async {
                completion(mediaItems)
            }
        }
        
        task.resume()
    }
    
    func comments(permalink: String, completion: @escaping ([Comment]) -> Void) {
        let session = URLSession(configuration: .default)
        //http://www.reddit.com/r/all/new.json
        let url = URL(string: "https://reddit.com/\(permalink).json")!
        let task = session.dataTask(with: url) {
            data, response, error in
            guard let data = data else { completion([]); return }
            let comments = self.parseCommentResponse(data: data)
            DispatchQueue.main.async {
                completion(comments)
            }
        }
        
        task.resume()
    }
    
    func parseResponse(data: Data) -> [Post] {
        guard let JSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary else {
            return []
        }
        after = (JSON?["data"] as? NSDictionary)?["after"] as? String
        guard let items = ((JSON?["data"] as? NSDictionary)?["children"] as? NSArray) else {
            return []
        }
        var posts = [Post]()
        for item in items {
            posts.append(Post.parse(dict: item as! NSDictionary))
        }

        return posts
    }
    
    func parseCommentResponse(data: Data) -> [Comment] {
        guard let JSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSArray else {
            return []
        }
        guard let items = (((JSON?[1] as? NSDictionary)?["data"] as? NSDictionary)?["children"] as? NSArray) else {
            return []
        }
        var comments = [Comment]()
        for item in items {
            comments.append(Comment.parse(dict: item as! NSDictionary))
        }
        
        return comments
    }
    
}
