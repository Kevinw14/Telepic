//
//  TabVC.swift
//  Telepic
//
//  Created by Michael Bart on 10/25/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Tabman
import Pageboy

class TabVC: TabmanViewController {

    private(set) var viewControllers: [TabChildVC]!
    
    let zoomTransitioningDelegate = ZoomTransitioningDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewControllers = [
            childViewController(withTitle: "Notifications"),
            childViewController(withTitle: "Forwards")
        ]
        self.bar.items = viewControllers.flatMap { Item(title: $0.pageTitle!) }
        
        self.dataSource = self
        
        self.bar.style = .buttonBar
        
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            
            appearance.style.background = .solid(color: .white)
            appearance.layout.height = .explicit(value: 45)
            appearance.indicator.color = UIColor(hexString: "#10BB6C")
            appearance.indicator.lineWeight = TabmanIndicator.LineWeight.normal
            appearance.indicator.compresses = true
            appearance.style.bottomSeparatorColor = UIColor(hexString: "#DBDBDB")
            
            appearance.state.selectedColor = UIColor(hexString: "#333333")
            appearance.text.font = UIFont(name: "AvenirNext-DemiBold", size: 17.0)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.edgesForExtendedLayout = []
        self.navigationController?.delegate = zoomTransitioningDelegate
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func childViewController(withTitle title: String) -> TabChildVC {
        let storyboard = UIStoryboard(name: "Notifications", bundle: nil)
        let identifier = title
        
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as! TabChildVC
        viewController.pageTitle = title
        viewController.delegate = self
        
        return viewController
    }

    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("SEGUE!!!!!!!!!!!!!!!!!")
    }

}

extension TabVC: PageboyViewControllerDataSource {
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}

extension TabVC: PresentMediaDelegate {
    @objc func presentMediaViewVC() {
        guard let image = FirebaseController.shared.photoToPresent?.image else { return }
        self.navigationController?.navigationBar.isHidden = true
        let mediaViewVC = UIStoryboard(name: "MediaView", bundle: nil).instantiateViewController(withIdentifier: Identifiers.mediaViewVC) as! MediaViewVC
        mediaViewVC.hidesBottomBarWhenPushed = true
        self.hidesBottomBarWhenPushed = true
        mediaViewVC.photo = image
        NotificationCenter.default.post(Notification(name: Notifications.didLoadMediaItem))
        self.navigationController?.pushViewController(mediaViewVC, animated: true)
    }
}

extension TabVC: ZoomingViewController {
    func zoomingBackgroundView(for transition: ZoomTransitioningDelegate) -> UIView? {
        return nil
    }
    
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        return FirebaseController.shared.photoToPresent!
    }
}
