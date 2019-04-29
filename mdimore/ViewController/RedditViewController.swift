//
//  RedditViewController.swift
//  mdimore
//
//  Created by Michael Dimore on 4/25/19.
//  Copyright © 2019 Michael Dimore. All rights reserved.
//

import UIKit
import SafariServices

class RedditViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var redditListingIndex = ListingIndex(before: "", after: "")
    var redditPosts = [RedditPost]()
    var timePeriod: String! {
        didSet {
            if timePeriod.count >= 3 {
                redditPosts.removeAll()
                redditListingIndex = ListingIndex(before: "", after: "")
                loadPosts()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "RedditPostTableViewCell", bundle: nil), forCellReuseIdentifier: "redditPostCell")
        loadPosts()
        timePeriod = "day"
    }
    
    @objc private func refreshPosts(_ sender: Any) {
        redditPosts.removeAll()
        redditListingIndex = ListingIndex(before: "", after: "")
        loadPosts()
    }
    
    private func loadPosts() {
        let networkManager = NetworkManager()
        networkManager.getRedditPosts(page: self.redditListingIndex.after, timeperiod: self.timePeriod) { listingIndex, posts, error in
            guard error == nil else { return }
            if let idx = listingIndex { self.redditListingIndex = idx }
            if let p = posts { self.redditPosts.append(contentsOf: p) }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if let paths = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at:paths, with: .automatic)
        }
    }
}

// MARK: - UITableViewDataSource
extension RedditViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mod = redditPosts.count > 0 ? 1 : 0
        return redditPosts.count + mod
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure a loading cell for the last row while the next group of posts are downloaded
        if indexPath.row >= redditPosts.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath)
            (cell.contentView.subviews.first as! UIActivityIndicatorView).startAnimating()
            return cell
        }
        
        // RedditPost result cell setup
        let cell = tableView.dequeueReusableCell(withIdentifier: "redditPostCell", for: indexPath) as! RedditPostTableViewCell
        let data = redditPosts[indexPath.row]
        cell.postData = data
        
        return cell
    }
    
    // Begin network request to load next group of reddit posts once the 'loading' cell is ready to display
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= redditPosts.count { loadPosts() }
    }
    
    // Return fixed row height for 'loading' cell, use automatic height for post cells
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= redditPosts.count { return 160.0 }
        return tableView.rowHeight
    }
}


// MARK: - UITableViewDelegate
extension RedditViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 200.0 {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else if scrollView.contentOffset.y < 0 {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}
