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
   
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
            
            //cell.thumbnails = thumbnails
            
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
