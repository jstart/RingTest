//
//  RedditTableViewController.swift
//  Ring_Test
//
//  Created by Christopher Truman on 3/4/17.
//  Copyright © 2017 Christopher Truman. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PostTableViewCell"

class RedditTableViewController: UITableViewController {
    
    var posts = [Post]()
    var segment : UISegmentedControl?
    var type = FeedType.top
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reddit"
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        
        segment = UISegmentedControl(items: ["Top", "Hot", "New"])
        segment?.selectedSegmentIndex = 0
        segment?.addTarget(self, action: #selector(changed), for: .valueChanged)
        tableView.tableHeaderView = segment!
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        RedditClient.shared.feed(type: type, completion: { posts in
            self.posts = posts
            self.tableView.reloadData()
        })
    }
    
    func changed() {
        switch segment!.selectedSegmentIndex {
        case 0: type = .top; break
        case 1: type = .hot; break
        case 2: type = .new; break
        default: type = .hot; break }
        refresh()
    }
    
    func refresh() {
        RedditClient.shared.feed(type: type, completion: { posts in
            self.posts = posts
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let vc = PostDetailTableViewController()
        vc.post = post
        navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! PostTableViewCell
        let post = posts[indexPath.row]
        cell.configure(post: post)
        cell.saveCallback = {
            self.presentSaveOptions(post: post)
        }
        
        if indexPath.row >= posts.count - 1 {
            fetchNextPage()
        }
        return cell
    }
    
    func presentSaveOptions(post: Post) {
        guard let imageURL = post.imageURL else { return }
        let task = URLSession.shared.downloadTask(with: URL(string: imageURL)!) {
            url, response, error in
            guard let url = url else { return }
            if let image = UIImage(data: try! Data(contentsOf: url)) {
                DispatchQueue.main.async {
                    let share = UIActivityViewController(activityItems: [image], applicationActivities: [])
                    self.present(share, animated: true)
                }
            }
        }
        task.resume()
    }
    
    func fetchNextPage() {
        RedditClient.shared.nextFeed(type: type, completion: { posts in
            self.posts.append(contentsOf: posts)
            self.tableView.reloadData()
        })
    }
}
