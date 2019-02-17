//
//  ExploreVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/23/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import FirebaseAuth

class ExploreVC: UIViewController {

    var categories = [String]()
    // Media items that have the most forwards, sorted by total forwards, then by newest
    var mostForwarded = [MediaItem]()
    // Media items that have traveled the most miles, sorted by miles, then by newest
    var mostMilesTraveled = [MediaItem]()
    
//    var contest = [MediaItem]()
    // Media Items that have 0 forwards, sorted by newest
//    var startAMovement = [MediaItem]()
    
    let zoomTransitioningDelegate = ZoomTransitioningDelegate()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        //refreshControl.tintColor = UIColor(hexString: "1BBB6A")
        
        return refreshControl
    }()
   
    let friendReuseID = "addFriendCell"
    
    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController!
    var friendsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let contestOfTheWeek = FirebaseController.remoteConfig["contestOfTheWeek"].stringValue ?? "Contest of the Week"
        self.categories = ["Categories", "Most Forwarded", "Most Miles Traveled"]
        
        
        self.tableView.addSubview(self.refreshControl)
        fetchData()
        
        friendsTableView = UITableView(frame: CGRect(x: 0, y: 44, width: self.view.frame.width, height: 0), style: .plain)
        
        friendsTableView.register(UINib(nibName: "AddFriendCell", bundle: nil), forCellReuseIdentifier: friendReuseID)
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        
        let titleView = ExploreNavigationTitleView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        
        navigationController?.navigationBar.topItem?.titleView = titleView
//        searchController = UISearchController(searchResultsController: nil)
//        self.view.insertSubview(friendsTableView, belowSubview: searchController.searchBar)
//        searchController.searchResultsUpdater = self
//        searchController.delegate = self
//        searchController.dimsBackgroundDuringPresentation = false
//        searchController.searchBar.searchBarStyle = .minimal
//        searchController.extendedLayoutIncludesOpaqueBars = true
//        searchController.searchBar.sizeToFit()
//        searchController.hidesNavigationBarDuringPresentation = false
//        tableView.tableHeaderView = searchController.searchBar
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: Notifications.didLoadUsers, object: nil)
    }
    
    @objc func updateData() {
        friendsTableView.reloadData()
    }
    
//    @objc func addFriendTapped() {
//        let addFriendVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "AddFriendVC") as! AddFriendVC
//        self.navigationController?.pushViewController(addFriendVC, animated: true)
//    }
    
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
    
//    func dismissSearch() {
//        searchController.isActive = false
//        searchController.dismiss(animated: true, completion: nil)
//    }
    
    func fetchData() {
        
        FirebaseController.shared.fetchMostForwarded { (mostForwarded) in
            self.mostForwarded = mostForwarded
            
            print("Most Forwarded: \(mostForwarded.count)")
            self.tableView.reloadData()
        }
        
        FirebaseController.shared.fetchFurthestTraveled { (mostMilesTraveled) in 
            self.mostMilesTraveled = mostMilesTraveled
            print("Most Traveled: \(mostMilesTraveled.count)")
            self.tableView.reloadData()
        }
        
//        FirebaseController.shared.fetchStartAMovement { (startAMovement) in
//            self.startAMovement = startAMovement
//            self.tableView.reloadData()
//        }
        
//        FirebaseController.shared.fetchContestOfTheWeek { (contestOfTheWeek) in
//            self.contest = contestOfTheWeek
//            self.tableView.reloadData()
//        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        fetchData()
        refreshControl.endRefreshing()
    }
}

//MARK: - SearchBar Delegate
extension ExploreVC: UISearchResultsUpdating, UISearchControllerDelegate {

    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            FirebaseController.shared.searchUsers(text: searchText.lowercased())
            friendsTableView.reloadData()
        }
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        self.view.addSubview(friendsTableView)
        UIView.animate(withDuration: 0.2) {
            self.friendsTableView.frame.size.height = self.view.frame.height / 2
        }
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.2, animations: {
            self.friendsTableView.frame.size.height = 0
        }) { (success) in
            if success {
                self.friendsTableView.removeFromSuperview()
                searchController.isActive = false
            }
        }
    }
}


//MARK: - TableView Delegate & Datasource
extension ExploreVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView != friendsTableView {
            return categories.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == friendsTableView {
            return FirebaseController.shared.filteredUsers.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if tableView != friendsTableView {
//
//            if indexPath.section == 2 {
//
//                let itemHeight = Constant.getItemWidth(boundWidth: tableView.bounds.size.width)
//
//                let totalRow = ceil(Constant.totalItem / Constant.column) // change totalItem to total number of photos by user, not a constatnt
//
//                let totalTopBottomOffset: CGFloat = 0.0
//
//                let totalSpacing = CGFloat(totalRow - 1) * Constant.minLineSpacing
//
//                let totalHeight  = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffset + totalSpacing)
//
//                return totalHeight
//            }
//            let itemsPerRow: CGFloat = 3.0
//            let paddingSpace: CGFloat = 2.0
//            let availableWidth = tableView.frame.width - paddingSpace
//            let widthPerItem = availableWidth / itemsPerRow
//
//            return widthPerItem
//        }
        
        if tableView != friendsTableView {
            if indexPath.section == 0 {
                return 110
            } else {
                return 350
            }
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == friendsTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: friendReuseID) as? AddFriendCell else { return UITableViewCell() }
            
            let user = FirebaseController.shared.filteredUsers[indexPath.row]
            
            cell.usernameLabel.text = user.username
            cell.uid = user.uid
            cell.delegate = self
            
            let url = URL(string: user.avatarURL)
            cell.avatarImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "avatar-1"), options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            return cell
        } else {
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryTableViewCell
                cell.selectionStyle = .none
                return cell
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ForwardCell") as? ForwardCell else { return UITableViewCell() }
                
                cell.mediaItems = mostForwarded
                cell.delegate = self
                cell.selectionStyle = .none
                return cell
            case 2:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MilesTraveledCell") as? MilesTraveledCell else { return UITableViewCell() }

                cell.mediaItems = mostMilesTraveled
                cell.delegate = self
                cell.selectionStyle = .none
                return cell
            default:
                return UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == friendsTableView {
            let user = FirebaseController.shared.filteredUsers[indexPath.row]
            segueToProfileVC(withUID: user.uid, username: user.username)
        }
    }
    
    func segueToProfileVC(withUID uid: String, username: String) {
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController()?.children[0] as! ProfileVC
        profileVC.userID = uid
        if Auth.auth().currentUser!.uid != uid {
            profileVC.isCurrentUser = false
            profileVC.username = username
        }
        
        DispatchQueue.main.async {
            FirebaseController.shared.fetchUser(uid: uid, completion: { (user) in
                profileVC.user = user
                NotificationCenter.default.post(Notification(name: Notifications.didLoadUser))
            })
        }
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView != friendsTableView {
            let headerView = Bundle.main.loadNibNamed("ExploreSectionHeaderView", owner: self, options: nil)?.first as! ExploreSectionHeaderView
            
            headerView.sectionLabel.text = categories[section]
            headerView.backgroundColor = .white
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView != friendsTableView {
            if section == 0 {
                return 0
            } else {
                return 55.0
            }
        }
        return 0
    }
}

extension ExploreVC: PresentMediaDelegate {
    @objc func presentMediaViewVC() {
        print("Should Present")
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

extension ExploreVC: AddFriendDelegate {
    func sendRequest(uid: String, cell: UITableViewCell) {
        FirebaseController.shared.sendFriendRequest(toUID: uid)
        let index = friendsTableView.indexPath(for: cell)?.row
        FirebaseController.shared.filteredUsers.remove(at: index!)
        tableView.reloadData()
    }
}
