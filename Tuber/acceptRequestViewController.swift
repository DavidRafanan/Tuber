//
//  acceptRequestViewController.swift
//  Tuber
//
//  Created by David Rafanan on 4/19/19.
//  Copyright © 2019 David Rafanan. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class acceptRequestViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    var requestLocation = CLLocationCoordinate2D()
    var tuberLocation = CLLocationCoordinate2D()
    var requestEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        map.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        
        map.addAnnotation(annotation)
    }
    

    @IBAction func acceptTubeTapped(_ sender: Any) {
        //update tube request
        Database.database().reference().child("tubeRequests").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) { (snapshot)
            in
            snapshot.ref.updateChildValues(["tuberLat": self.tuberLocation.latitude, "tuberLon": self.tuberLocation.longitude])
            Database.database().reference().child("TubeRequests").removeAllObservers()

        }
        
        //give directions
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let placeMark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: placeMark)
                    mapItem.name = self.requestEmail     //person that is requesting tube
                    let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
