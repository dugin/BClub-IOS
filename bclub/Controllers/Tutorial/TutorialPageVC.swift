//
//  TutorialPageVC.swift
//  bclub
//
//  Created by Douglas on 07/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import UIKit
import SwiftyColor

class TutorialPageVC: UIPageViewController {
    
    // MARK: - Properties
    
    let pageTitleList = ["FAÇA PARTE\nDO MAIOR CLUBE\nDE VANTAGENS\nPARA MULHERES\nDO BRASIL.",
                         "ESCOLHA UM DE\nNOSSOS PLANOS E\nTENHA DESCONTOS\nNOS MELHORES\nESTABELECIMENTOS.",
                         "ENCONTRE OS\nMELHORES SERVIÇOS\nDE BELEZA E BEM ESTAR\nE GASTE ATÉ 50% MENOS!"]
    
    let pageBackgroundList = ["bg_splash_01", "bg_splash_02", "bg_splash_03"]
    
    var currentIndex = 0
    var nextIndex = 1
    
    var currentPageView: TutorialContentVC!
    var nextPageView: TutorialContentVC!
    
    var scrollView: UIScrollView!
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialValues()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let subViews = view.subviews
        var pageControl: UIPageControl?
        
        for view in subViews {
            if view.isKindOfClass(UIScrollView) {
                scrollView = view as? UIScrollView
            }
            else if view.isKindOfClass(UIPageControl) {
                pageControl = view as? UIPageControl
                //pageControl?.frame = CGRect(x: (pageControl?.frame.origin.x)!, y: (pageControl?.frame.origin.y)! - 80, width: (pageControl?.frame.size.width)!, height: (pageControl?.frame.size.height)!)
                pageControl?.frame = CGRect(x : -120, y: (pageControl?.frame.origin.y)! - 80, width: (pageControl?.frame.size.width)! , height : (pageControl?.frame.size.height)!)
                pageControl?.currentPageIndicatorTintColor = Color.bclRosyPinkColor()
            }
        }
        
        if scrollView != nil && pageControl != nil {
            scrollView?.frame = view.bounds
            view.bringSubviewToFront(pageControl!)
        }
    }
    
    // MARK: - Helpers
    
    func setupInitialValues() {
        dataSource = self
        delegate = self
        
        let pageContentViewController = viewControllerAtIndex(0)
        currentPageView = pageContentViewController as! TutorialContentVC
        setViewControllers([pageContentViewController!], direction: .Forward, animated: true, completion: nil)
    }
    
    func viewControllerAtIndex(index : Int) -> UIViewController? {
        if pageTitleList.count == 0 || index >= pageTitleList.count {
            return nil
        }
        
        let pageContentVC = self.storyboard?.instantiateViewControllerWithIdentifier("PageContentVC") as! TutorialContentVC
        
        pageContentVC.pageIndex = index
        pageContentVC.titleText = pageTitleList[index]
        pageContentVC.backgroundImage = UIImage(named: pageBackgroundList[index])
        
        return pageContentVC
    }
    
    func scrollToNext() {
        if let nextVC = viewControllerAtIndex(currentIndex + 1) as? TutorialContentVC {
            nextIndex = nextVC.pageIndex
            nextPageView = nextVC
            
            currentIndex = self.nextIndex
            currentPageView = self.nextPageView
            nextIndex = 0
            
            setViewControllers([nextVC], direction: .Forward, animated: true, completion: nil)
        }
        else {
            var defaults = NSUserDefaults.standardUserDefaults()
            //defaults.tutorialWasPresented = true
            let navController = presentingViewController as! UINavigationController
            let promotionListVC = navController.viewControllers[0] as! PromotionListVC
            
            dismissViewControllerAnimated(true) {
                promotionListVC.splashWasShowed = false
                promotionListVC.startCustomLoading()
                promotionListVC.locationManager = LocationManager()
                promotionListVC.setupLocationManager()
                promotionListVC.locationManager.requestUserLocation()
            }
        }
    }
}

// MARK: - UIPageViewController Protocols

extension TutorialPageVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! TutorialContentVC).pageIndex!
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        
        if index == pageTitleList.count {
            return nil
        }
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! TutorialContentVC).pageIndex!
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        index -= 1
        return viewControllerAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageTitleList.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {        
        return currentIndex
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        let pageContentVC = pendingViewControllers.first as! TutorialContentVC
        nextIndex = pageContentVC.pageIndex
        nextPageView = pageContentVC
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentIndex = nextIndex
            currentPageView = nextPageView
        }
        nextIndex = 0
    }
    
}
