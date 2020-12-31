//
//  Search.swift
//  StoreSearch12
//
//  Created by Buck Rozelle on 12/30/20.
//

import Foundation

typealias SearchComplete = (Bool) -> Void

class Search {
    
    private var dataTask: URLSessionDataTask?
    private(set) var state: State = .notSearchedYet
    
    enum State {
        case notSearchedYet
        case loading
        case noResults
        case results([SearchResult])
    }
    
    enum Category: Int {
        case all = 0
        case music = 1
        case software = 2
        case ebooks = 3
        
        var type: String {
            switch self {
            case .all: return ""
            case .music: return "musicTrack"
            case .software: return "software"
            case .ebooks: return "ebook"
            }
        }
    }
    
    
    //Create the URL for the request
    private func iTunesURL(searchText: String, category: Category) -> URL {
        let kind = category.type
    //enables the search to handle special characters
            let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let urlString = "https://itunes.apple.com/search?" + "term=\(encodedText)&limit=200&entity=\(kind)"
            let url = URL(string: urlString)
            return url!
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
    
    func performSearch(for text:
                        String, category: Category,
                       completion: @escaping SearchComplete) {
        print("Searching...")
//None of this will happen unless the user types something into the search field.
        if !text.isEmpty {
            
//Cancels the data task if there is another one entered in the search bar.
            dataTask?.cancel()
            
            state = .loading

        //Create the URL Object
        let url = iTunesURL(searchText: text,
                            category: category)
            //Get a shared URLSession instance. This uses the default config with respect to caching, cookies, and other web stuff.
            let session = URLSession.shared
        //Create a data task to fetch the contents of the URL.
          dataTask = session.dataTask(with: url) {
            data, response, error in
            var success = false
            var newState = State.notSearchedYet
        /*“Data, response, or error If error is nil, the communication with the server succeeded;
                 response holds the server’s response code and headers,
                 and data contains the actual data fetched from the server, in this case a blob of JSON.*/
            if let error = error as NSError?, error.code == -999 {
              return
                }
            if let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
      //Parses the data into usable SearchResults data
                    let data = data {
                var searchResults = self.parse(data: data)
                        if searchResults.isEmpty {
                          newState = .noResults
                        } else {
                          searchResults.sort(by: <)
                          newState = .results(searchResults)
                        }
                        success = true
                      }
                      // Remove "if !success" block
                      DispatchQueue.main.async {
                        self.state = newState                        // add this
                        completion(success)
                      }
                    }
                    dataTask?.resume()
                  }
                }
}
