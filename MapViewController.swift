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
    var location: CLLocation?
    var user: PFUser?
    var username: String?
    var profilePic: UIImage?
    
    @IBOutlet weak var updateAddressButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func updateAddress(sender: AnyObject) {
        //Update the user's address -- implement this later.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        if let usr = user {
            username = usr["name"] as? String
        }
        self.navigationItem.title = "\(username!)'s address"
        
        if let coord = location?.coordinate{
            let region = MKCoordinateRegionMakeWithDistance(coord, 2000, 2000)
            mapView.setRegion(region, animated: true)
            placeAnnotation()
        }
    }
    
    func placeAnnotation() {
        let pin = MapPin(coordinate: location!.coordinate, title: "\(username!)'s address", subtitle: nil)
        mapView.addAnnotation(pin)
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
    
}
