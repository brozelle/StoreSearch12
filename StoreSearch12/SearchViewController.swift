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
    var isLoading = false
    
    
    //Cell Reuse identifiers
        struct TableView {
            struct CellIdentifiers {
                static let searchResultCell = "SearchResultCell"
                static let nothingFoundCell = "NothingFoundCell"
                static let loadingCell = "LoadingCell"
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//Gives the search bar room to breath.
        tableView.contentInset = UIEdgeInsets(top: 50,
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

    //Create the URL for the request.
    func iTunesURL(searchText: String) -> URL {
//enables the search to handle special characters
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200",
                             encodedText)
      let url = URL(string: urlString)
    
      return url!
    }

    //Returns a new JSON Data object from the server.
    func performStoreRequest(with url:URL) -> Data? {
        do {
            return try Data(contentsOf: url)
        } catch {
            print("Download Error: \(error.localizedDescription)")
            showNetworkError()
            return nil
        }
    }

    //Use a JSONdecoder to convert the data to a ResultArray object to extract the results property.
    func parse(data: Data) -> [SearchResult] {
      do {
        let decoder = JSONDecoder()
        let result = try decoder.decode(ResultArray.self,
                                        from: data)
        return result.results
      } catch {
        print("JSON Error: \(error)")
        return []
      }
    }
    
    //Error Alert
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...",
                                      message: "There was an error accessing the iTunes Store." + " Please try again.",
                                      preferredStyle: .alert)
      
        let action = UIAlertAction(title: "OK",
                                   style: .default,
                                   handler: nil)
        alert.addAction(action)
        
        present(alert,
              animated: true,
              completion: nil)
    }
    
}

//MARK:- Seach Bar Delegate
extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//None of this will happen unless the user types something into the search field.
        if !searchBar.text!.isEmpty {
          searchBar.resignFirstResponder()
            
            isLoading = true
            tableView.reloadData()
   
            hasSearched = true
            searchResults = []
/*This is a reference to a global queue provided by the system. It is part of
     the system.
 */
            let queue = DispatchQueue.global()
            let url = self.iTunesURL(searchText: searchBar.text!)
                //Dispatches a closure on the queue. After this, the main thread is free to continue.
                queue.async {
                  if let data = self.performStoreRequest(with: url) {
                    self.searchResults = self.parse(data: data)
                    self.searchResults.sort(by: <)
                    //Makes the loading nib go away when done.
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.tableView.reloadData()
                    }
                    return
                  }
                }
              }
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
        if isLoading {
            return 1
        }else if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
          } else {
            return searchResults.count
          }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//Only make a SearchResultsCell if there are results.
    if isLoading {
            let cell = tableView.dequeueReusableCell(
              withIdentifier: TableView.CellIdentifiers.loadingCell,
              for: indexPath)
                
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
          } else if searchResults.count == 0 {
        return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell,
                                             for: indexPath)
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell,
                                                 for: indexPath) as! SearchResultCell
//Puts the artists name into the name label.
        let searchResult = searchResults[indexPath.row]
        cell.nameLabel.text = searchResult.name
            //Check to see if the artist is not empty. If it is, then display unknown.
        if searchResult.artist.isEmpty {
          cell.artistNameLabel.text = "Unknown"
        } else {
          cell.artistNameLabel.text = String(
            format: "%@ (%@)",
            searchResult.artist,
            searchResult.type)
        }
        cell.artistNameLabel.text = searchResult.artistName
        return cell
      }
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
          if searchResults.count == 0 || isLoading {
            return nil
          } else {
            return indexPath
          }
        }
}
