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
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//Gives the search bar room to breath.
        tableView.contentInset = UIEdgeInsets(top: 50,
                                              left: 0,
                                              bottom: 0,
                                              right: 0)
        print("This is the fucking console")
    }

}

//MARK:- Seach Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
          searchResults = []
        
        if searchBar.text! != "justin bieber" {
        for i in 0...2 {
            let searchResult = SearchResult()
            searchResult.name = String(format: "Fake Result %d for",
                                       i)
            searchResult.artistName = searchBar.text!
            searchResults.append(searchResult)
          }
        }
    print("The search text is: '\(searchBar.text!)'")
        hasSearched = true
          tableView.reloadData()
        }
    
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
        
    }

//MARK:- Table View Delegates
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
//Table will be empty if nothing has been searched yet.
        if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
          } else {
            return searchResults.count
          }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellIdentifier = "SearchResultCell"
          
          var cell: UITableViewCell! = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier)
          
        if cell == nil {
            cell = UITableViewCell(style: .subtitle,
                                   reuseIdentifier: cellIdentifier)
            }
if searchResults.count == 0 {
          cell.textLabel!.text = "(Nothing found)"
          cell.detailTextLabel!.text = ""
        } else {
          let searchResult = searchResults[indexPath.row]
          cell.textLabel!.text = searchResult.name
          cell.detailTextLabel!.text = searchResult.artistName
        }
          return cell
    }
    
//deselects the row with animation.
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath
    ) {
      tableView.deselectRow(at: indexPath,
                            animated: true)
}
          
        func tableView(_ tableView: UITableView,
                       willSelectRowAt indexPath: IndexPath) -> IndexPath? {
          if searchResults.count == 0 {
            return nil
          } else {
            return indexPath
          }
        }
}
