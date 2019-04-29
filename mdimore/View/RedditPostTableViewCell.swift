//
//  RedditPostTableViewCell.swift
//  mdimore
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
        setupGestureRecognizer()
        reset()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    private func reset() {
        thumbnailHandler = nil
        thumbnailImageView.cancelDownload()
        thumbnailImageView.image = nil
        titleTextView.text = nil
        commentCountLabel.text = nil
        authorLabel.text = nil
        postedDateLabel.text = nil
    }
    
    
    @objc private func thumbnailImagePressed() {
        thumbnailHandler?()
    }
    
    private func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(thumbnailImagePressed))
        thumbnailImageView.isUserInteractionEnabled = true
        thumbnailImageView.addGestureRecognizer(tapRecognizer)
    }
    
    var postData: RedditPost? {
        didSet {
            if let data = postData { loadPost(data: data) }
        }
    }
    
    func loadPost(data: RedditPost) {
        self.titleTextView.text = data.title
        self.subredditNameLabel.text = "r/\(data.subreddit ?? "")"
        self.commentCountLabel.text = data.commentCount.formatUsingAbbrevation()
        self.postedDateLabel.text = data.dateCreated.timeAgoPosted()
        self.authorLabel.text = "u/\(data.author)"
        
        if let icon = data.srDetail?.icon { subredditIconImageView.loadFrom(url: icon, animated: true) }
        if let thumb = data.thumbnail { thumbnailImageView.loadFrom(url: thumb, animated: true) }
        
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

