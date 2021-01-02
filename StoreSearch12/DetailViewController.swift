//
//  DetailViewController.swift
//  StoreSearch12
//
//  Created by Buck Rozelle on 12/24/20.
//
//
//NSLocalizedString("E-Book", comment: "Localized kind: E-Book")
//
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var popupView: UIView!
    @IBOutlet var artworkImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var kindLabel: UILabel!
    @IBOutlet var genreLabel: UILabel!
    @IBOutlet var priceButton: UIButton!
    
    var searchResult: SearchResult!
    var downloadTask: URLSessionDownloadTask?
    enum AnimationStyle {
      case slide
      case fade
    }

    var dismissStyle = AnimationStyle.fade

//Cancel image download if user closes pop-up before image has been completely downloaded.
    deinit {
      print("******deinit******* \(self)")
      downloadTask?.cancel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        transitioningDelegate = self
    }
    
    @IBAction func close() {
        dismissStyle = .slide
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func openInStore() {
      if let url = URL(string: searchResult.storeURL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 10
        //listens for taps anywhere in this view controller and calls the close method in response.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        if searchResult != nil {
            updateUI()
        }
        //Gradient View
        view.backgroundColor = UIColor.clear
        let dimmingView = GradientView(frame: CGRect.zero)
        dimmingView.frame = view.bounds
        view.insertSubview(dimmingView, at: 0)

    }
    
    // MARK: - Helper Methods
    func updateUI() {
        nameLabel.text = searchResult.name
        if searchResult.artist.isEmpty {
        artistNameLabel.text = NSLocalizedString("Unknown", comment: "Unknown")
    
      } else {
        artistNameLabel.text = searchResult.artist
      }
      
      kindLabel.text = searchResult.type
      genreLabel.text = searchResult.genre

    
    // Show price
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = searchResult.currency

    let priceText: String
    if searchResult.price == 0 {
      priceText = NSLocalizedString("Free", comment: "Free")
    } else if let text = formatter.string(from: searchResult.price as NSNumber) {
      priceText = text
    } else {
      priceText = ""
    }

    priceButton.setTitle(priceText, for: .normal)
        // Get image
        if let largeURL = URL(string: searchResult.imageLarge) {
          downloadTask = artworkImageView.loadImage(url: largeURL)
        }
        
    }

}

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                            presenting: UIViewController,
                            source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      switch dismissStyle {
      case .slide:
        return SlideOutAnimationController()
      case .fade:
        return FadeOutAnimationController()
      }
    }
}
