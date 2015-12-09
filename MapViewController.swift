//
//  MapViewController.swift
//  Connect
//
//  Created by Abiel Gutierrez on 12/3/15.
//  Copyright © 2015 Abiel Gutierrez. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    let user = PFUser.currentUser()
    var isPersonalMap = true
    var viewTitle: String?
    var username: String?
    var profilePic: UIImage?
    let manager = (UIApplication.sharedApplication().delegate as! AppDelegate).manager
    var location: CLLocation?
    
    @IBOutlet weak var updateAddressButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func updateAddress(sender: AnyObject) {
        user!["address"] = PFGeoPoint(location: location!)
        user!.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                let alert = UIAlertController.createAlert("Address Saved!")
                self.presentViewController(alert, animated: true, completion: nil)
            } else if let err = error {
                let alert = UIAlertController.createAlert("Error", withMessage: err.description)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.navigationItem.title = viewTitle!
        updateAddressButton.hidden = true
        manager.delegate = self
        //Distinguishes between searching and displaying current location or simply displaying
        //a location that is given by Parsez
        if isPersonalMap{
            manager.requestLocation()
        } else {
            setMapRegion()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alert = UIAlertController.createAlert("Error", withMessage: error.description)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
        setMapRegion()
    }
    
    func placeAnnotation() {
        print("hi")
        let pin = MapPin(coordinate: location!.coordinate, title: "\(username!)'s address", subtitle: nil)
        mapView.addAnnotation(pin)
        activityIndicator.stopAnimating()
        if isPersonalMap{
            updateAddressButton.hidden = false
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view: MKAnnotationView! = mapView.dequeueReusableAnnotationViewWithIdentifier("addressAnnotation")
        if view == nil{
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "addressAnnotation")
            view.canShowCallout = true
            let imgView = UIImageView(image: profilePic!)
            imgView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            view.leftCalloutAccessoryView = imgView
            view.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
            view.draggable = true
        }
        view.annotation = annotation
        return view
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let placemark = MKPlacemark(coordinate: self.location!.coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(username!)'s address"
        mapItem.openInMapsWithLaunchOptions(nil)
        //Referenced: http://stackoverflow.com/questions/28604429/how-to-open-maps-app-programatically-with-coordinates-in-swift
    }
    
    func setMapRegion(){
        if let coord = location?.coordinate{
            let region = MKCoordinateRegionMakeWithDistance(coord, 2000, 2000)
            mapView.setRegion(region, animated: true)
            placeAnnotation()
        }
    }
    
}
