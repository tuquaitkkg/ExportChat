//
//  PageVC.swift
//  CallSantaChristmas
//
//  Created by Dat Duong on 12/9/17.
//  Copyright © 2017 Dat Duong. All rights reserved.
//

import UIKit

class PageVC: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    
    var pageControl = UIPageControl()
    
    // MARK: UIPageViewControllerDataSource
    
    let orderedViewControllers: [UIViewController] = {
        let storyboard = UIStoryboard(name: "Page", bundle: Bundle.main)
        
        var viewControllers = [UIViewController]()
        for i in 0 ..< 4 {
            if i < 4 {
                let viewController = storyboard.instantiateViewController(withIdentifier: "ChildViewController") as! PageChildrentVC
                viewController.index = i + 1
                viewControllers.append(viewController)
            } else {
                let viewController = storyboard.instantiateViewController(withIdentifier: "PurchaseVC") as! PurchaseVC
                viewControllers.append(viewController)
            }
            
        }
        return viewControllers
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        // This sets up the first view that will show up on our page control
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
//        configurePageControl()
        
        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.purple
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.red
        self.view.addSubview(pageControl)
    }
    
    func newVc(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Page", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    
    // MARK: Delegate methords
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
    }
    
    // MARK: Data source functions.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        if previousIndex == 0 {
            //Call TabbarVC
            self.callTabbar()
        }
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
//            return orderedViewControllers.last
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
             return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
//            return orderedViewControllers.first
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
             return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func callTabbar() {
        let app = UIApplication.shared.delegate as! AppDelegate
        let tabbarSB = UIStoryboard(name: "Tabbar", bundle: nil)
        let viewcontroller : UITabBarController = tabbarSB.instantiateViewController(withIdentifier: "Tabbar") as! UITabBarController
        viewcontroller.selectedIndex = 1
        app.window?.rootViewController = viewcontroller
        app.window?.makeKeyAndVisible()
    }
}
