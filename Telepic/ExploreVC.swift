//
//  ExploreVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/23/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class ExploreVC: UIViewController {

    let categories = ["Most Forwarded", "Most Miles Traveled", "Start a Movement"]
    var thumbnails = [InboxItem]()
    let item1 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "michaelbart", senderAvatar: #imageLiteral(resourceName: "avatar"), creator: "stephaniejoyce", creatorAvatar: #imageLiteral(resourceName: "avatar2"), daysRemaining: 2, commentsRef: "22j9jfs", mapRef: "j24j209jf")
    let item2 = InboxItem(photo: #imageLiteral(resourceName: "photo2"), sender: "stephaniejoyce", senderAvatar: #imageLiteral(resourceName: "avatar2"), creator: "michaelbart", creatorAvatar: #imageLiteral(resourceName: "avatar"), daysRemaining: 3, commentsRef: "j3oij2f", mapRef: "jfo23j209f")
    let item3 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "stevejobs", senderAvatar: #imageLiteral(resourceName: "avatar3"), creator: "donaldtrump", creatorAvatar: #imageLiteral(resourceName: "avatar4"), daysRemaining: 4, commentsRef: "jfiajfelei", mapRef: "jofij293")
    let item4 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "michaelbart", senderAvatar: #imageLiteral(resourceName: "avatar"), creator: "stephaniejoyce", creatorAvatar: #imageLiteral(resourceName: "avatar2"), daysRemaining: 2, commentsRef: "22j9jfs", mapRef: "j24j209jf")
    let item5 = InboxItem(photo: #imageLiteral(resourceName: "photo2"), sender: "stephaniejoyce", senderAvatar: #imageLiteral(resourceName: "avatar2"), creator: "michaelbart", creatorAvatar: #imageLiteral(resourceName: "avatar"), daysRemaining: 3, commentsRef: "j3oij2f", mapRef: "jfo23j209f")
    let item6 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "stevejobs", senderAvatar: #imageLiteral(resourceName: "avatar3"), creator: "donaldtrump", creatorAvatar: #imageLiteral(resourceName: "avatar4"), daysRemaining: 4, commentsRef: "jfiajfelei", mapRef: "jofij293")
    let item7 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "michaelbart", senderAvatar: #imageLiteral(resourceName: "avatar"), creator: "stephaniejoyce", creatorAvatar: #imageLiteral(resourceName: "avatar2"), daysRemaining: 2, commentsRef: "22j9jfs", mapRef: "j24j209jf")
    let item8 = InboxItem(photo: #imageLiteral(resourceName: "photo2"), sender: "stephaniejoyce", senderAvatar: #imageLiteral(resourceName: "avatar2"), creator: "michaelbart", creatorAvatar: #imageLiteral(resourceName: "avatar"), daysRemaining: 3, commentsRef: "j3oij2f", mapRef: "jfo23j209f")
    let item9 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "stevejobs", senderAvatar: #imageLiteral(resourceName: "avatar3"), creator: "donaldtrump", creatorAvatar: #imageLiteral(resourceName: "avatar4"), daysRemaining: 4, commentsRef: "jfiajfelei", mapRef: "jofij293")
    let item10 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "michaelbart", senderAvatar: #imageLiteral(resourceName: "avatar"), creator: "stephaniejoyce", creatorAvatar: #imageLiteral(resourceName: "avatar2"), daysRemaining: 2, commentsRef: "22j9jfs", mapRef: "j24j209jf")
    let item11 = InboxItem(photo: #imageLiteral(resourceName: "photo2"), sender: "stephaniejoyce", senderAvatar: #imageLiteral(resourceName: "avatar2"), creator: "michaelbart", creatorAvatar: #imageLiteral(resourceName: "avatar"), daysRemaining: 3, commentsRef: "j3oij2f", mapRef: "jfo23j209f")
    let item12 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "stevejobs", senderAvatar: #imageLiteral(resourceName: "avatar3"), creator: "donaldtrump", creatorAvatar: #imageLiteral(resourceName: "avatar4"), daysRemaining: 4, commentsRef: "jfiajfelei", mapRef: "jofij293")
    let item13 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "michaelbart", senderAvatar: #imageLiteral(resourceName: "avatar"), creator: "stephaniejoyce", creatorAvatar: #imageLiteral(resourceName: "avatar2"), daysRemaining: 2, commentsRef: "22j9jfs", mapRef: "j24j209jf")
    let item14 = InboxItem(photo: #imageLiteral(resourceName: "photo2"), sender: "stephaniejoyce", senderAvatar: #imageLiteral(resourceName: "avatar2"), creator: "michaelbart", creatorAvatar: #imageLiteral(resourceName: "avatar"), daysRemaining: 3, commentsRef: "j3oij2f", mapRef: "jfo23j209f")
    let item15 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "stevejobs", senderAvatar: #imageLiteral(resourceName: "avatar3"), creator: "donaldtrump", creatorAvatar: #imageLiteral(resourceName: "avatar4"), daysRemaining: 4, commentsRef: "jfiajfelei", mapRef: "jofij293")
    let item16 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "michaelbart", senderAvatar: #imageLiteral(resourceName: "avatar"), creator: "stephaniejoyce", creatorAvatar: #imageLiteral(resourceName: "avatar2"), daysRemaining: 2, commentsRef: "22j9jfs", mapRef: "j24j209jf")
    let item17 = InboxItem(photo: #imageLiteral(resourceName: "photo2"), sender: "stephaniejoyce", senderAvatar: #imageLiteral(resourceName: "avatar2"), creator: "michaelbart", creatorAvatar: #imageLiteral(resourceName: "avatar"), daysRemaining: 3, commentsRef: "j3oij2f", mapRef: "jfo23j209f")
    let item18 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "stevejobs", senderAvatar: #imageLiteral(resourceName: "avatar3"), creator: "donaldtrump", creatorAvatar: #imageLiteral(resourceName: "avatar4"), daysRemaining: 4, commentsRef: "jfiajfelei", mapRef: "jofij293")
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        thumbnails = [item1,item2,item3,item4,item5,item6,item7,item8,item9,item10,item11,item12,item13,item14,item15,item16,item17,item18]
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
        if indexPath.section == 2 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "startAMovementCell") as? StartAMovementCell else { return UITableViewCell() }
            
            cell.thumbnails = thumbnails
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryRow") as? CategoryRowCell else { return UITableViewCell() }
        
            cell.thumbnails = thumbnails
        
            return cell
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
