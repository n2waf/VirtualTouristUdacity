//
//  PhotosViewController.swift
//  VirtualTouristUdacity
//
//  Created by nF ™ on 18/08/2020.
//  Copyright © 2020 nF ™. All rights reserved.
//

import UIKit
import MapKit
import Kingfisher

class PhotosViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource {

    @IBOutlet weak var PhotosCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    var photosURL = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("View Did Load - Photos Count = \(photosURL.count)")
        PhotosCollectionView.reloadData()
        // Do any additional setup after loading the view.
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photosURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = PhotosCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotosCollectionViewCell
        let url = URL(string: photosURL[indexPath.row])
        cell.Image.kf.setImage(with: url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        photosURL.remove(at: indexPath.row)
        PhotosCollectionView.deleteItems(at: [indexPath])
    }



}
