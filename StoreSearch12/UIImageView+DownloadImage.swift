//
//  UIImageView+DownloadImage.swift
//  StoreSearch12
//
//  Created by Buck Rozelle on 12/23/20.
//


import UIKit

extension UIImageView {
  func loadImage(url: URL) -> URLSessionDownloadTask {
    let session = URLSession.shared
    //Get a shared URLSession reference and create a download task.
    let downloadTask = session.downloadTask(with: url) {
      [weak self] url, _, error in
      //Find the downloaded file in the URL
      if error == nil, let url = url,
        let data = try? Data(contentsOf: url),
        //Load the file into a Data object.
        let image = UIImage(data: data) {
        //Put the image into the UIImageView's image property.
        DispatchQueue.main.async {
          if let weakSelf = self {
            weakSelf.image = image
          }
        }
      }
    }
    //Gives the app the opportunity to cancel the download task if necessary.
    downloadTask.resume()
    return downloadTask
  }
}
