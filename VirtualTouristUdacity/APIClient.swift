//
//  APIClient.swift
//  VirtualTouristUdacity
//
//  Created by nF ™ on 17/08/2020.
//  Copyright © 2020 nF ™. All rights reserved.
//

import Foundation
import Kingfisher

let apiKey = "ee1ab39a32ebb844138e825d30ba76cd"
let SearchMethod = "flickr.photos.search"
let PhotosSetMethod = "flickr.photosets.getPhotos"
enum EndPoints {
    case searchPhotos(String,String,String)
    case getPhotoURL(String,String,String,String)
    
    var StringValue : String {
        switch self {
        case .searchPhotos(let lat,let lon, let page):
            return "https://api.flickr.com/services/rest?api_key=\(apiKey)&method=\(SearchMethod)&lat=\(lat)&lon=\(lon)&format=json&per_page=10&page=\(page)&accuracy=11&nojsoncallback=1"
        case .getPhotoURL(let farm , let server , let photoID , let secret):
            return "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_b.jpg"
        }
    }
    var url :URL {
        return URL(string: self.StringValue)!
    }
}

class APIClient {
    
    class func downloadImages(_ url : URL ,completion: @escaping (Data?,Error?) -> Void) {
        KingfisherManager.shared.retrieveImage(with: url) { result in
            do {
                let img = try result.get().image.imageWithoutBaseline()
                let imgData = img.jpegData(compressionQuality: 1)
                completion(imgData , nil)
            } catch {
                completion(nil , error)
            }
            
        }
    }
    class func photosSearch(lat: Double , lon : Double , page : String,completion: @escaping (Flicker?,Error?) -> Void)  {
      
        let url = EndPoints.searchPhotos("\(lat)", "\(lon)", page).url
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(nil,error)
                return }
            
        do {
            let reponseObject = try JSONDecoder().decode(Flicker.self, from: data)
           
            completion(reponseObject,nil)
        } catch {
            print("failed of decode")
            completion(nil,error)
            }
        }
        task.resume()
    }
}
