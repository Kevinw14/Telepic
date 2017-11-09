//
//  SendPageVC.swift
//  Telepic
//
//  Created by Michael Bart on 11/3/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class SendPageVC: UIPageViewController {

    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVC(viewController: "SelectFriendsVC"),
                self.newVC(viewController: "SelectGroupsVC")]
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func newVC(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension SendPageVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        // Prevenst user from swiping left at the first VC to get to the last VC
        guard previousIndex >= 0 else { return nil }
        
        guard orderedViewControllers.count > previousIndex else { return nil }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else { return nil }
        guard orderedViewControllersCount > nextIndex else { return nil }
        
        return orderedViewControllers[nextIndex]
    }
    
    
}

extension SendPageVC: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
//        guard let sendVC = self.parent as? SendVC else { return }
//
//        if let _ = pendingViewControllers[0] as? SelectFriendsVC {
//            sendVC.isSelectingGroups = false
//        } else {
//            sendVC.isSelectingGroups = true
//        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let sendVC = self.parent as? SendVC else { return }
        
        if completed {
            if let _ = previousViewControllers[0] as? SelectFriendsVC {
                sendVC.isSelectingGroups = true
            } else {
                sendVC.isSelectingGroups = false
            }
        }
    }
}

extension SendPageVC: PagingDelegate {
    func nextPage() {
        guard let currentPage = self.viewControllers?.first else { return }
        
        guard let nextPage = self.pageViewController(self, viewControllerAfter: currentPage) else { return }
        
        setViewControllers([nextPage], direction: .forward, animated: true, completion: nil)
    }
    
    func previousPage() {
        guard let currentPage = self.viewControllers?.first else { return }
        
        guard let previousPage = self.pageViewController(self, viewControllerBefore: currentPage) else { return }
        
        setViewControllers([previousPage], direction: .reverse, animated: true, completion: nil)
    }
}
