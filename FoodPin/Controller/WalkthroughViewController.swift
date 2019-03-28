//
//  WalkthroughViewController.swift
//  FoodPin
//
//  Created by Makan Fofana on 2/26/19.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit
protocol WalkthroughPageViewControllerDelegate: class {
    func didUpdatePageIndex(currentIndex: Int)
}

class WalkthroughViewController: UIViewController, WalkthroughPageViewControllerDelegate {
    
    var walkthroughPageViewController: WalkthroughPageViewController?
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var nextButton: UIButton! {
        didSet {
            nextButton.layer.cornerRadius = 25.0
            nextButton.layer.masksToBounds = true
        }
    }
    @IBOutlet var skipButton: UIButton!
    
    //Skip button for master walktrough view controller
    @IBAction func skipButtonTapped(sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
        createQuickActions()
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //Obtaining reference to the Walkthrough Page view controller 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? WalkthroughPageViewController {
            walkthroughPageViewController = pageViewController
            walkthroughPageViewController?.walkthroughDelegate = self
        }
    }
    
    //Updating the UI For the Walkthrough Page View Controller
    func updateUI() {
        
        if let index = walkthroughPageViewController?.currentIndex {
            switch (index) {
            case 0...1:
                nextButton.setTitle("NEXT", for: .normal)
                skipButton.isHidden = false
            case 2:
                nextButton.setTitle("GET STARTED", for: .normal)
                skipButton.isHidden = true
            default:
                break;
            }
            
            pageControl.currentPage = index
        }
    }
    
    //Page View Controller Protocol Method
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }

    //Next Button
    @IBAction func nextButtonTapped(sender: UIButton) {
        
        if let index = walkthroughPageViewController?.currentIndex {
            switch (index) {
            case 0...1:
                walkthroughPageViewController?.forwardPage()
            case 2:
                UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
                createQuickActions()
                dismiss(animated: true, completion: nil)
            default:
                break;
                
            }
            
        }
        
        updateUI()
        
    }
    
    func createQuickActions() {
        
        //Adding A Quick Action
        if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
            if let bundleIdentifier = Bundle.main.bundleIdentifier {
                let shortcutItem1 = UIApplicationShortcutItem(type: "com.MakanFofana.ComedyApp.OpenFavorites)", localizedTitle: "Comedy Show Favorites", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "favorite"), userInfo: nil)
                let shortcutItem2 = UIApplicationShortcutItem(type: "com.MakanFofana.ComedyApp.OpenDiscover", localizedTitle: "Discover Comedy Shows", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "discover"), userInfo: nil)
                let shortcutItem3 = UIApplicationShortcutItem(type: "com.MakanFofana.ComedyApp.NewComedyShow", localizedTitle: "New Comedy Show", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .add), userInfo: nil)
                
                UIApplication.shared.shortcutItems = [shortcutItem1, shortcutItem2, shortcutItem3]
            }
        }
    }
    
    
//    case OpenFavorites = "OpenFavorites"
//    case OpenDiscover = "OpenDiscover"
//    case NewComedyShow = "NewComedyShow"
    
    
    //

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
