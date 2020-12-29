//
//  LandscapeViewController.swift
//  StoreSearch12
//
//  Created by Buck Rozelle on 12/26/20.
//

import UIKit

class LandscapeViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    var searchResults = [SearchResult]()
    private var firstTime = true
    //keeps track of all the urlsessiondownloadtask objects.
    private var downloads = [URLSessionDownloadTask]()
    //Stops download for any button whose image is still in transit.
    deinit {
        print("deinit \(self)")
            for task in downloads {
            task.cancel()
        }
    }
    
    // MARK: - Actions
    @IBAction func pageChanged(_ sender: UIPageControl) {
      scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width * CGFloat(sender.currentPage),
                                         y: 0)
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
        // Remove constraints from main view
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        // Remove constraints for page control
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        // Remove constraints for scroll view
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        pageControl.numberOfPages = 0
        
    }
    

    override func viewWillLayoutSubviews() {
      super.viewWillLayoutSubviews()
      let safeFrame = view.safeAreaLayoutGuide.layoutFrame
  //scroll view is as large as entire screen.
        scrollView.frame = safeFrame
            //sets page control constraints.
        pageControl.frame = CGRect(x: safeFrame.origin.x,
                                 y: safeFrame.size.height - pageControl.frame.size.height,
                                 width: safeFrame.size.width,
                                 height: pageControl.frame.size.height)
        if firstTime {
            firstTime = false
            tileButtons(searchResults)
        }
    }
    
    // MARK: - Private Methods
    private func tileButtons(_ searchResults: [SearchResult]) {
        let itemWidth: CGFloat = 94
        let itemHeight: CGFloat = 88
        var columnsPerPage = 0
        var rowsPerPage = 0
        var marginX: CGFloat = 0
        var marginY: CGFloat = 0
        let viewWidth = scrollView.bounds.size.width
        let viewHeight = scrollView.bounds.size.height
        
        //Calculates the number of columns needed.
        columnsPerPage = Int(viewWidth / itemWidth)
        rowsPerPage = Int(viewHeight / itemHeight)
        //Calculate the amount of space left over horizontally/2 and then get horizontal padding
        marginX = (viewWidth - (CGFloat(columnsPerPage) * itemWidth)) * 0.5
        marginY = (viewHeight - (CGFloat(rowsPerPage) * itemHeight)) * 0.5
        
        // Button size
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth) / 2
        let paddingVert = (itemHeight - buttonHeight) / 2
        
        // Add the buttons
        var row = 0
        var column = 0
        var x = marginX
        for (index, result) in searchResults.enumerated() {
          //Create the button object
            let button = UIButton(type: .custom)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"),
                                      for: .normal)
            downloadImage(for: result, andPlaceOn: button)
            
          //set its frame.
          button.frame = CGRect(
            x: x + paddingHorz,
            y: marginY + CGFloat(row) * itemHeight + paddingVert,
            width: buttonWidth,
            height: buttonHeight)
          //add the object to the scroll view.
          scrollView.addSubview(button)
          //position the button.
            row += 1
            if row == rowsPerPage {
              row = 0; x += itemWidth; column += 1
              if column == columnsPerPage {
                column = 0; x += marginX * 2
              }
            }
          }
        // Set scroll view content size
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        scrollView.contentSize = CGSize(width: CGFloat(numPages) * viewWidth,
                                        height: scrollView.bounds.size.height)
//sets the number of dots to the number of pages calculated.
        print("Number of pages: \(numPages)")
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
        
    }
    
    private func downloadImage(for searchResult: SearchResult,
                               andPlaceOn button: UIButton) {
        if let url = URL(string: searchResult.imageSmall) {
            let task = URLSession.shared.downloadTask(with: url) {
                [weak button] url, _, error in
                if error == nil, let url = url,
                   let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if let button = button {
                            button.setImage(image, for: .normal)
                        }
                    }
                }
            }
            task.resume()
            downloads.append(task)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//Connects the scrollview and the pageview.
extension LandscapeViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let width = scrollView.bounds.size.width
    let page = Int((scrollView.contentOffset.x + width / 2) / width)
    pageControl.currentPage = page
  }
}
