//
//  TutorialViewController.swift
//  ExportChats
//
//  Created by Duc.LT on 7/20/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var clTutorial: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    var arrayImg : NSArray! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrayImg = ["tutorial_img1","tutorial_img2","tutorial_img3","tutorial_img4"]
        pageControl.numberOfPages = 4
        if #available(iOS 11.0, *) {
            clTutorial.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayImg.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TutorialCollectionViewCell
        let nameImg = arrayImg.object(at: indexPath.row) as! String
        cell.imageView?.image = UIImage(named: nameImg);
        cell.btnNext.isHidden = true
        if indexPath.row == arrayImg.count - 1 {
            cell.btnNext.isHidden = false
        }
        cell.clickNext = {
            UserDefaults.standard.set(true, forKey: "isTutorial")
            UserDefaults.standard.synchronize()
            self.performSegue(withIdentifier: "tutorialToInApp", sender: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return clTutorial.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        currentPage()
    }
    
    func currentPage() -> Void {
        var visibleRect = CGRect()
        
        visibleRect.origin = clTutorial.contentOffset
        visibleRect.size = clTutorial.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let indexPath = clTutorial.indexPathForItem(at: visiblePoint) else { return }
        
        pageControl.currentPage = indexPath.row
        print(indexPath)
    }

}
