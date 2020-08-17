//
//  ViewController.swift
//  VirtualTouristUdacity
//
//  Created by nF ™ on 17/08/2020.
//  Copyright © 2020 nF ™. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController , MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    var annotationArray = [MKPointAnnotation]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var locations  = [Annotations]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchData()
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        gestureRecognizer.minimumPressDuration = 0.3
        mapView.delegate = self
        
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    func fetchData() {
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Annotations")
        do {
            let results = try context.fetch(fetchRequest)
            locations = results as! [Annotations]
           
            addAnnotations(locations)
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
    }
    
    func addAnnotations(_ data:[Annotations]) {
        var desc = [MKPointAnnotation]()
        
        for i in data {

            let latitude = CLLocationDegrees(exactly: i.latitude)
            let longitude = CLLocationDegrees(exactly: i.longitude)
          //  CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            
            let annotation = MKPointAnnotation()
            annotation.title = "Flickr Photos"
            annotation.coordinate = coordinate
            desc.append(annotation)
        }
        DispatchQueue.main.async {
            self.mapView.addAnnotations(desc)
        }
        
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoLight)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let coordinate = view.annotation?.coordinate {
               
                var URLs = [String]()
                APIClient.photosSearch(lat: coordinate.latitude, lon: coordinate.longitude, page: "\(Int.random(in: 1...6))") { (data, error) in
                    guard let photos = data?.photos?.photo else {
                        return
                    }
                    for i in photos {
                        let url = EndPoints.getPhotoURL("\(i.farm)", "\(i.server)", "\(i.id)", "\(i.secret)").url.absoluteString
                       
                        URLs.append(url)
                    }
 
                    DispatchQueue.main.async {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhotosShow") as! PhotosViewController
                        vc.photosURL = URLs
                        self.present(vc,animated: true)
                    }
                    
                }
                

              
            }
        }
    }
    
    @objc private func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let touch: CGPoint = gesture.location(in: self.mapView)
            let coordinate: CLLocationCoordinate2D = self.mapView.convert(touch, toCoordinateFrom: self.mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            getLocationName(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (name) in
                if name != "error" {
                    annotation.title = name
                } else {
                    annotation.title = "Location Name Not Founded"
                }
            }
            self.annotationArray.append(annotation)
            mapView.addAnnotation(annotation)
            saveToCoreData(annotation)
            self.mapView.setCenter(coordinate, animated: true)
        }
    }
    
    func getLocationName(location :CLLocation, completion:@escaping (String?) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            placemarks?.forEach { (placemark) in
                
                guard let city = placemark.locality else {
                    completion("error")
                    return
                }
                completion(city)
            }
            
        })
        
    }
    
    func saveToCoreData(_ annotations : MKPointAnnotation) {
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Annotations", in: context)
        let newAnnotation = NSManagedObject(entity: entity!, insertInto: context)
        newAnnotation.setValue(annotations.coordinate.latitude, forKey: "latitude")
        newAnnotation.setValue(annotations.coordinate.longitude, forKey: "longitude")
        newAnnotation.setValue(annotations.title, forKey: "name")
        
        do {
            print("Saved !")
            try context.save()
        } catch {
            print("Failed saving")
        }
        
    }
}

