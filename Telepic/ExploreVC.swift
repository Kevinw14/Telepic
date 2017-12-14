//
//  ExploreVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/23/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class ExploreVC: UIViewController {

    var categories = [String]()
    // Media items that have the most forwards, sorted by total forwards, then by newest
    var mostForwarded = [MediaItem]()
    // Media items that have traveled the most miles, sorted by miles, then by newest
    //var mostMilesTraveled = [MediaItem]()
    var contest = [MediaItem]()
    // Media Items that have 0 forwards, sorted by newest
    var startAMovement = [MediaItem]()
    
    let zoomTransitioningDelegate = ZoomTransitioningDelegate()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        //refreshControl.tintColor = UIColor(hexString: "1BBB6A")
        
        
        return refreshControl
    }()
   
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let contestOfTheWeek = FirebaseController.remoteConfig["contestOfTheWeek"].stringValue ?? "Contest of the Week"
        self.categories = ["Most Forwarded", contestOfTheWeek, "Start a Movement"]
        
        
        self.tableView.addSubview(self.refreshControl)
        fetchData()
        
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "addFriend"), for: .normal)
        //btn.sizeToFit()
        btn.height(40)
        btn.width(40)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20)
        btn.addTarget(self, action: #selector(addFriendTapped), for: .touchUpInside)
        let barBtn = UIBarButtonItem(customView: btn)
        
        self.navigationItem.rightBarButtonItem = barBtn
    }
    
    @objc func addFriendTapped() {
        let addFriendVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "AddFriendVC") as! AddFriendVC
        self.navigationController?.pushViewController(addFriendVC, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.edgesForExtendedLayout = []
        self.navigationController?.delegate = zoomTransitioningDelegate
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = .white
    }
    
    func fetchData() {
        FirebaseController.shared.fetchMostForwarded { (mostForwarded) in
            self.mostForwarded = mostForwarded
            //self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            self.tableView.reloadData()
        }
        
        FirebaseController.shared.fetchStartAMovement { (startAMovement) in
            self.startAMovement = startAMovement
            self.tableView.reloadData()
        }
        
        FirebaseController.shared.fetchContestOfTheWeek { (contestOfTheWeek) in
            self.contest = contestOfTheWeek
            self.tableView.reloadData()
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        fetchData()
        refreshControl.endRefreshing()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ExploreVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            
            let itemHeight = Constant.getItemWidth(boundWidth: tableView.bounds.size.width)
            
            let totalRow = ceil(Constant.totalItem / Constant.column) // change totalItem to total number of photos by user, not a constatnt
            
            let totalTopBottomOffset: CGFloat = 0.0
            
            let totalSpacing = CGFloat(totalRow - 1) * Constant.minLineSpacing
            
            let totalHeight  = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffset + totalSpacing)
            
            return totalHeight
        }
        let itemsPerRow: CGFloat = 3.0
        let paddingSpace: CGFloat = 2.0
        let availableWidth = tableView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return widthPerItem
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryRow") as? CategoryRowCell else { return UITableViewCell() }
            
            cell.mediaItems = mostForwarded
            cell.delegate = self

            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryRow") as? CategoryRowCell else { return UITableViewCell() }
            
            cell.mediaItems = contest
            cell.isLocalCategory = true
            cell.delegate = self
            
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "startAMovementCell") as? StartAMovementCell else { return UITableViewCell() }
            
            cell.mediaItems = startAMovement
            cell.delegate = self

            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("ExploreSectionHeaderView", owner: self, options: nil)?.first as! ExploreSectionHeaderView
        
        headerView.sectionLabel.text = categories[section]

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
}

extension ExploreVC: PresentMediaDelegate {
    @objc func presentMediaViewVC() {
        guard let image = FirebaseController.shared.photoToPresent?.image else { return }
        self.navigationController?.navigationBar.isHidden = true
        let mediaViewVC = UIStoryboard(name: "MediaView", bundle: nil).instantiateViewController(withIdentifier: Identifiers.mediaViewVC) as! MediaViewVC
        mediaViewVC.hidesBottomBarWhenPushed = true
        self.hidesBottomBarWhenPushed = true
        mediaViewVC.photo = image
        self.navigationController?.pushViewController(mediaViewVC, animated: true)
    }
}

extension ExploreVC: ZoomingViewController {
    func zoomingBackgroundView(for transition: ZoomTransitioningDelegate) -> UIView? {
        return nil
    }
    
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        return FirebaseController.shared.photoToPresent!
    }
}

protocol PresentMediaDelegate: class {
    func presentMediaViewVC()
}
