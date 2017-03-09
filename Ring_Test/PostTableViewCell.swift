//
//  PostTableViewCell.swift
//  Ring_Test
//
//  Created by Christopher Truman on 3/5/17.
//  Copyright © 2017 Christopher Truman. All rights reserved.
//

import UIKit
import AVFoundation

class PostTableViewCell: UITableViewCell {

    let titleLabel = UILabel(translates: false)
    let mediaView = UIImageView(translates: false)
    var post : Post?
    var const : NSLayoutConstraint?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(titleLabel); addSubview(mediaView)
        
        titleLabel.numberOfLines = 0
        const = mediaView.constraint(.height, toItem: self, toAttribute: .width, multiplier: 0.5)
        const?.isActive = true
        mediaView.constrain(.width, toItem: self, multiplier: 0.5)

        mediaView.constrain((.top, 10), (.centerX, 0), toItem: self)
        let topConstraint = titleLabel.constraint(.top, constant: 10, toItem: mediaView, toAttribute: .bottom)
        topConstraint.priority = 999
        topConstraint.isActive = true
        titleLabel.constrain((.left, 10), (.right, -10), toItem: self)
        titleLabel.constrain((.bottom, -10), toItem: self)
        
        mediaView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(openImage))
        mediaView.addGestureRecognizer(tap)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        mediaView.image = nil
        mediaView.backgroundColor = .white
    }
    
    func openImage() {
        guard let post = post else { return }
        guard let imageURL = URL(string: post.URL) else { return }

        UIApplication.shared.open(imageURL, options: [:])
    }
    
    func configure(post: Post) {
        self.post = post
        if post.commentCount == 1 {
            titleLabel.text = "\(post.caption)\nAuthor: \(post.author)\nPosted Date: \(post.createdAt.timeAgoSinceNow(useNumericDates: false)) \n\(post.commentCount) comment"
        } else {
            titleLabel.text = "\(post.caption)\nAuthor: \(post.author)\nPosted Date: \(post.createdAt.timeAgoSinceNow(useNumericDates: false)) \n\(post.commentCount) comments"
        }
        guard let imageURL = post.imageURL else { return }

        let task = URLSession.shared.downloadTask(with: URL(string: imageURL)!) {
            url, response, error in
            guard let url = url else { self.mediaView.backgroundColor = .gray; return }
            if let image = UIImage(data: try! Data(contentsOf: url)) {
                DispatchQueue.main.async {
                    self.mediaView.alpha = 0.0
                    UIView.animate(withDuration: 0.2, animations: {
                        self.mediaView.image = image
                        self.mediaView.alpha = 1.0
                    })
                }
            }
        }
        task.resume()
    }
    
    func configure(comment: Comment) {
        const?.isActive = false
        if comment.replyCount == 1 {
            titleLabel.text = comment.body + "\n\n \(comment.replyCount) reply to this comment."
        } else {
            titleLabel.text = comment.body + "\n\n \(comment.replyCount) replies to this comment."
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
