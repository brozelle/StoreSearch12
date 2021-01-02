//
//  SearchViewController.swift
//  StoreSearch12
//
//  Created by Buck Rozelle on 12/21/20.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    private let search = Search()
    var landscapeVC: LandscapeViewController?
    
    
    
    //Cell Reuse identifiers
        struct TableView {
            struct CellIdentifiers {
                static let searchResultCell = "SearchResultCell"
                static let nothingFoundCell = "NothingFoundCell"
                static let loadingCell = "LoadingCell"
            }
        }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
        print("Segment Changed: \(sender.selectedSegmentIndex)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//Gives the search bar room to breath.
        tableView.contentInset = UIEdgeInsets(top: 94,
                                              left: 0,
                                              bottom: 0,
                                              right: 0)
//Loads the SearchResultCell NIB!
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell,
                            bundle: nil)
        tableView.register(cellNib,
                           forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
//Loads the LoadingCell NIB!
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell,
                        bundle: nil)
        tableView.register(cellNib,
                           forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        
        searchBar.becomeFirstResponder()
        print("This is the fucking console")
    }

// MARK: - Helper Methods

    
    //Error Alert
    func showNetworkError() {
        let alert = UIAlertController(title: NSLocalizedString("Whoops...", comment: "Error Alert: title"),
                                      message: NSLocalizedString("There was an error accessing the iTunes Store." + " Please try again.", comment: "Error Alert: message"),
                                      preferredStyle: .alert)
      
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"),
                                   style: .default,
                                   handler: nil)
        alert.addAction(action)
        
        present(alert,
              animated: true,
              completion: nil)
    }
    
func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
      //if the landscape mode is not nil then return right away (landscape vc is showing.)
      guard landscapeVC == nil else { return }
      //Finds the scene with the id "LandscapeViewController" and instantiates it.
      landscapeVC = storyboard!.instantiateViewController(
        withIdentifier: "LandscapeViewController") as? LandscapeViewController
      if let controller = landscapeVC {
        //Passes the array to the LandscapeViewController searchResult property
        controller.search = search
        //Sets the size and position of the view controller.
        controller.view.frame = view.bounds
        //landscape view starts out transparent and slowly fades in.
        controller.view.alpha = 0
        //Steps to add new view controller.
        view.addSubview(controller.view)
        addChild(controller)
            coordinator.animate(
              alongsideTransition: { _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                //dismisses the detail pop-up
                if self.presentedViewController != nil {
                  self.dismiss(animated: true, completion: nil)
                }
              }, completion: { _ in
                controller.didMove(toParent: self)
              })
      }
    }

    //unembeds the landscape view controller
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
      if let controller = landscapeVC {
        controller.willMove(toParent: nil)
        coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 0
              }, completion: { _ in
                controller.view.removeFromSuperview()
                controller.removeFromParent()
                self.landscapeVC = nil
                if self.presentedViewController != nil {
                  self.dismiss(animated: true, completion: nil)
                }
              })
      }
    }

// MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "ShowDetail" {
        if case .results(let list) = search.state {
          let detailViewController = segue.destination as! DetailViewController
          let indexPath = sender as! IndexPath
          let searchResult = list[indexPath.row]
          detailViewController.searchResult = searchResult
        }
      }
    }
// Invoked during device rotation and when the trait collection for the veiw controller changes.
    
    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
      super.willTransition(to: newCollection,
                           with: coordinator)

      switch newCollection.verticalSizeClass {
      case .compact:
        showLandscape(with: coordinator)
      case .regular, .unspecified:
        hideLandscape(with: coordinator)
      @unknown default:
        break
      }
    }
}



//MARK:- Seach Bar Delegate
extension SearchViewController: UISearchBarDelegate {

    func performSearch() {
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
      search.performSearch(for: searchBar.text!,
                           category: category) {
        success in
          if !success {
            self.showNetworkError()
          }
          self.tableView.reloadData()
        self.landscapeVC?.searchResultsReceived()
        }
      
      tableView.reloadData()
      searchBar.resignFirstResponder()
    }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
        
    }

//MARK:- Table View Delegates
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(
      _ tableView: UITableView,
      numberOfRowsInSection section: Int
    ) -> Int {
      switch search.state {
      case .notSearchedYet:
        return 0
      case .loading:
        return 1
      case .noResults:
        return 1
      case .results(let list):
        return list.count
      }
    }
    
    func tableView(
      _ tableView: UITableView,
      cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
      switch search.state {
      case .notSearchedYet:
        fatalError("Should never get here")
      
      case .loading:
        let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell,
                                                 for: indexPath)
        
        let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
        spinner.startAnimating()
        return cell
      
      case .noResults:
        return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell,
                                             for: indexPath)
            
          case .results(let list):
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell,
                                                     for: indexPath) as! SearchResultCell
            
            let searchResult = list[indexPath.row]
            cell.configure(for: searchResult)
            return cell
          }
        }
    

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath,
                            animated: true)
        performSegue(withIdentifier: "ShowDetail",
                     sender: indexPath)
}
          
    func tableView(_ tableView: UITableView,
                   willSelectRowAt indexPath: IndexPath) -> IndexPath? {
      switch search.state {
      case .notSearchedYet, .loading, .noResults:
        return nil
      case .results:
        return indexPath
      }
    }
}
