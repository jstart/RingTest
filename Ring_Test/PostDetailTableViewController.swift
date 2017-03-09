//
//  PostDetailTableViewController.swift
//  Ring_Test
//
//  Created by Christopher Truman on 3/6/17.
//  Copyright © 2017 Christopher Truman. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PostTableViewCell"

class PostDetailTableViewController: UITableViewController {

    var post: Post?
    var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = post?.caption
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open in Web", style: .done, target: self, action: #selector(openInWeb))
        
        RedditClient.shared.comments(permalink: post!.permalink, completion: { comments in
            self.comments = comments
            self.tableView.reloadData()
        })
        
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func openInWeb(){
        UIApplication.shared.open(URL(string: "https://reddit.com/\(post!.permalink)")!, options: [:])
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! PostTableViewCell
        let comment = comments[indexPath.row]
        cell.configure(comment: comment)
        
        return cell
    }

}
