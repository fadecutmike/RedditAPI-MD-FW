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
    
    private let refreshControl = UIRefreshControl()
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
        tableView.register(UINib(nibName: "RedditPostTableViewCell", bundle: nil), forCellReuseIdentifier: "redditPostCell")
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPosts(_:)), for: .valueChanged)
        timePeriod = "day"
        let vvv = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width/2.0, height: 30.0))
        let imgv = UIImageView(image: UIImage(named: "fleetwit-wide"))
        vvv.addSubview(imgv)
        navigationItem.titleView = vvv
        imgv.center = vvv.center        
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
                self.refreshControl.endRefreshing()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if let paths = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at:paths, with: .automatic)
        }
    }
    
    @IBAction func optionsBtnPressed(_ sender: Any) {
        let popupDialog = UIAlertController(title: "", message: "Top Posts From", preferredStyle: .actionSheet)
        popupDialog.addAction(UIAlertAction(title: "Today", style: .default, handler: { (action) in self.timePeriod = "day" }))
        popupDialog.addAction(UIAlertAction(title: "This Week", style: .default, handler: { (action) in self.timePeriod = "week" }))
        popupDialog.addAction(UIAlertAction(title: "This Month", style: .default, handler: { (action) in self.timePeriod = "month" }))
        popupDialog.addAction(UIAlertAction(title: "This Year", style: .default, handler: { (action) in self.timePeriod = "year" }))
        popupDialog.addAction(UIAlertAction(title: "All", style: .default, handler: { (action) in self.timePeriod = "all" }))
        popupDialog.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(popupDialog, animated: true, completion: nil)
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
        
        // Closure connecting thumbnail image taps back to controller
        cell.thumbnailHandler = { [weak self] in
            self?.openPhotoView(data: data)
        }
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
        openWebView(data: redditPosts[indexPath.row])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 200.0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else if scrollView.contentOffset.y < 0, !tableView.refreshControl!.isRefreshing {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}


// MARK: - Segue Items
extension RedditViewController {
    
    func openPhotoView(data:RedditPost) {
        if data.isImageURL(), let img = data.url {
            self.performSegue(withIdentifier: "openPhotoView", sender: img)
        }
    }
    
    func openWebView(data:RedditPost) {
        if let link = data.pageURL {
            let svc = SFSafariViewController(url: link)
            present(svc, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "openPhotoView" {
            let vc = segue.destination as! PhotoViewController
            vc.photoURL = sender as? String
        }
    }
}
