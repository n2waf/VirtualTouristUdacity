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
import CoreData

class PhotosViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var PhotosCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    var photosURL = [String]()
    var imagesData = [Data]()
    var coordinate : CLLocationCoordinate2D?
    var pinData : PinEntity?
    var page = 1
    
   
    
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>()
    
    
    
    var activityIN : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 100 ,y: 200, width: 50, height: 50)) as UIActivityIndicatorView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setAnnotation(coordinate!)
        fetchedResultController = getFetchedResultController()
        fetchedResultController.delegate = self
        
        do {
            try self.fetchedResultController.performFetch()
            if self.fetchedResultController.fetchedObjects?.count == nil {
                getData()
            }
        } catch _ {
            }
        
        activityIN.center = self.view.center
        activityIN.hidesWhenStopped = true
        activityIN.style = UIActivityIndicatorView.Style.large
        activityIN.color = .label
        activityIN.startAnimating()
        self.view.addSubview(activityIN)
        activityIN.stopAnimating()
        
    }
    
    @IBAction func Update(_ sender: Any) {
        deleteObjcets()
        activityIN.startAnimating()
        page = page + 1
        getData()
    }
    
    func getData() {
        APIClient.photosSearch(lat: coordinate!.latitude, lon: coordinate!.longitude, page: "\(page)") { (data, error) in
            guard let photos = data?.photos?.photo else {
                return
            }
            for i in photos {
                let url = EndPoints.getPhotoURL("\(i.farm)", "\(i.server)", "\(i.id)", "\(i.secret)").url
                APIClient.downloadImages(url) { (data, error) in
                    guard let img = data else {
                        return
                    }
                    self.saveToCoreData(img)
                }
                
            }
            DispatchQueue.main.async {
                self.activityIN.stopAnimating()
            }
        }
    }
    func setAnnotation(_ location:CLLocationCoordinate2D) {

            let latitude = CLLocationDegrees(exactly: location.latitude)
            let longitude = CLLocationDegrees(exactly: location.longitude)
            //  CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
        
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
            self.mapView.setCenter(coordinate, animated: true)
        }
        
    }


    func saveToCoreData(_ imgData: Data) {
        let entityDescripition = NSEntityDescription.entity(forEntityName: "PhotoEntity", in: managedObjectContext)
        let photo = PhotoEntity(entity: entityDescripition!, insertInto: managedObjectContext)
        
        let pinEntityDes = NSEntityDescription.entity(forEntityName: "PinEntity", in: managedObjectContext)
        let pin = PinEntity(entity: pinEntityDes!, insertInto: managedObjectContext)
        
        
        pin.longitude = coordinate!.longitude as Double
        pin.latitude = coordinate!.latitude as Double
        
        photo.photoData = imgData
        photo.toPin = pin
        do {
            try managedObjectContext.save()
            print("Saved")
        } catch _ {
            }
    }
    


    func deleteObjcets() -> Void {
        let context = managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoEntity")
        fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@", argumentArray:["toPin.latitude", Double(coordinate!.latitude), "toPin.longitude", Double(coordinate!.longitude)])
        
        let result = try? context.fetch(fetchRequest)
        let resultData = result as! [PhotoEntity]
        
        for object in resultData {
            context.delete(object)
        }
        
        do {
            try context.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
    }


}

// MARK: CollectionView
extension PhotosViewController : UICollectionViewDelegate , UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfRowsInSection = fetchedResultController.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = PhotosCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotosCollectionViewCell
        let img = fetchedResultController.object(at: indexPath as IndexPath) as! PhotoEntity
        cell.Image.image = UIImage(data:img.photoData!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let managedObject:NSManagedObject = fetchedResultController.object(at: indexPath as IndexPath) as! NSManagedObject
        managedObjectContext.delete(managedObject)
        do {
            try managedObjectContext.save()
        } catch _ {
        }
    }
}

// MARK: NSFetchController
extension PhotosViewController : NSFetchedResultsControllerDelegate{
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        PhotosCollectionView.reloadData()
    }

    func getFetchedResultController() -> NSFetchedResultsController<NSFetchRequestResult> {
        fetchedResultController = NSFetchedResultsController(fetchRequest: taskFetchRequest(),  managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
    }
    
    func taskFetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoEntity")
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@", argumentArray:["toPin.latitude", Double(coordinate!.latitude), "toPin.longitude", Double(coordinate!.longitude)])
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }

}
