//
//  RedditPostTableViewCell.swift
//  rtest
//
//  Created by Michael Dimore on 4/28/19.
//  Copyright © 2019 Michael Dimore. All rights reserved.
//

import UIKit

class RedditPostTableViewCell: UITableViewCell {
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var subredditIconImageView: UIImageView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var subredditNameLabel: UILabel!
    @IBOutlet weak var postedDateLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var separatorLine: UIView!
    @IBOutlet weak var authorLabel: UILabel!
    
    var thumbnailHandler: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        thumbnailImageView.layer.cornerRadius = 8.0
        thumbnailImageView.image = UIImage(named: "default-thumb")
        titleTextView.textContainerInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        reset()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    private func reset() {
        thumbnailHandler = nil
        thumbnailImageView.image = nil
        titleTextView.text = nil
        commentCountLabel.text = nil
        authorLabel.text = nil
        postedDateLabel.text = nil
    }
    
    var postData: RedditPost? {
        didSet {
            if let data = postData { loadPost(data: data) }
        }
    }
    
    func loadPost(data: RedditPost) {
        self.titleTextView.text = data.title
        self.subredditNameLabel.text = "r/\(data.subreddit ?? "")"
        
        // TODO: Process date posted string. Setup number formatter for comment count to read '1.1k' etc.
        
        self.authorLabel.text = "u/\(data.author)"
        
        // TODO: Download and set thumbnail and subreddit icon images
        
        self.layoutIfNeeded()
    }
    
    override public func layoutSubviews() {
        self.applyTextExclusionRect()
        super.layoutSubviews()
    }
    
    func applyTextExclusionRect() {
        var rect = convert(self.thumbnailImageView.frame, to: self.titleTextView)
        rect.size.width += 60.0
        self.titleTextView.textContainer.exclusionPaths = [UIBezierPath(rect: rect)]
    }
}

