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
//Added &limit=200 to artificially slow down search.
        let urlString = String(format: "https://itunes.apple.com/search?term=%@",
                             encodedText)
      let url = URL(string: urlString)
    
      return url!
    }

    //Returns a new JSON Data object from the server.
    

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

        //Create the URL Object
            let url = iTunesURL(searchText: searchBar.text!)
        //Get a shared URLSession instance. This uses the default config with respect to caching, cookies, and other web stuff.
            let session = URLSession.shared
        //Create a data task to fetch the contents of the URL.
            let dataTask = session.dataTask(with: url) {data, response, error in
        /*“Data, response, or error If error is nil, the communication with the server succeeded;
                 response holds the server’s response code and headers,
                 and data contains the actual data fetched from the server, in this case a blob of JSON.*/
            if let error = error {
                  print("Failure! \(error.localizedDescription)")
                } else if let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 {
      //Parses the data into usable SearchResults data
                    if let data = data {
                      self.searchResults = self.parse(data: data)
                      self.searchResults.sort(by: <)
                      DispatchQueue.main.async {
                        self.isLoading = false
                        self.tableView.reloadData()
                      }
                      return
                    }
                  print("Success! \(data!)")
                } else {
                  print("Failure! \(response!)")
                }
                    DispatchQueue.main.async {
                      self.hasSearched = false
                      self.isLoading = false
                      self.tableView.reloadData()
                      self.showNetworkError()
                    }
                }
            //One the data task is created, call resume to start it.
                    dataTask.resume()
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
