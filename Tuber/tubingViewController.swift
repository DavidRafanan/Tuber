//
//  tubingViewController.swift
//  Tuber
//
//  Created by David Rafanan on 4/18/19.
//  Copyright © 2019 David Rafanan. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class tubingViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var callTuber: UIButton!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var tubeIsComing = false
    var tuberIsOnTheWay = false
    var tuberLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //if there is a current ride request 
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("TubeRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded,
                with: { (snapshot) in
                self.tubeIsComing = true
                self.callTuber.setTitle("Cancel Tube", for: .normal)  //will cancel tube
                
                //remove references from database
                Database.database().reference().child("TubeRequests").removeAllObservers()
                    
                    if let tubeRequestDictionary = snapshot.value as? [String:AnyObject] {
                        if let tuberLat = tubeRequestDictionary["tuberLat"] as? Double {
                            if let tuberLon = tubeRequestDictionary["tuberLon"] as? Double {
                                self.tuberLocation = CLLocationCoordinate2D(latitude: tuberLat, longitude: tuberLon)
                                self.tuberIsOnTheWay = true
                                self.displayTuberAndTubeReceiver()
                                
                                //updates current location of tube as it's coming closer
                                if let email = Auth.auth().currentUser?.email {
                                    Database.database().reference().child("tubeRequests").queryOrdered(byChild: email).queryEqual(toValue: email).observe(.childChanged, with: {
                                        (snapshot) in
                                        
                                        if let tubeRequestDictionary = snapshot.value as? [String:AnyObject] {
                                            if let tuberLat = tubeRequestDictionary["tuberLat"] as? Double {
                                                if let tuberLon = tubeRequestDictionary["tuberLon"] as? Double {
                                                    self.tuberLocation = CLLocationCoordinate2D(latitude: tuberLat, longitude: tuberLon)
                                                    self.tuberIsOnTheWay = true
                                                    self.displayTuberAndTubeReceiver()
                                                }
                                            }
                                        }
                                        
                                    })
                                }
                            }
                        }
                    }
            })
        }
    }
    
    func displayTuberAndTubeReceiver() { //displays tuber and one being tubed and shows current location
        let tuberCLLocation = CLLocation(latitude: tuberLocation.latitude, longitude: tuberLocation.longitude)
        let tubingCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        let distance = tuberCLLocation.distance(from: tubingCLLocation) / 1000
        let roundedDistance = round(distance * 100) / 100
        
        callTuber.setTitle("Your tube is \(roundedDistance)km way!", for: .normal)
        
        map.removeAnnotations(map.annotations)
        
        let latDelta = abs(tuberLocation.latitude - userLocation.latitude) * 2 + 0.005
        let lonDelta = abs(tuberLocation.longitude - userLocation.longitude) * 2 + 0.005
        
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        
        map.setRegion(region, animated: true)
        
        let tubingAnno = MKPointAnnotation()
        tubingAnno.coordinate = userLocation
        tubingAnno.title = "Your Location"
        map.addAnnotation(tubingAnno)
        
        let tuberAnno = MKPointAnnotation()
        tuberAnno.coordinate = tuberLocation
        tuberAnno.title = "Your Tube's Current Location"
        map.addAnnotation(tuberAnno)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = manager.location?.coordinate {
            //sets point in map
            let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            userLocation = center
            
            if tubeIsComing {
                displayTuberAndTubeReceiver()
                
            } else {
                //sets region to zoom into
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    
                //zooms into region
                map.setRegion(region, animated: true)
                    
                //removes past annotations (points)
                map.removeAnnotations(map.annotations)
                    
                //sets current annotation (current location)
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                annotation.title = "Your Location"
                map.addAnnotation(annotation)
            }
        }
    }
    
    @IBAction func getTubedTapped(_ sender: Any) {
        
        if !tuberIsOnTheWay { //check if true, then do following
        
        if let email = Auth.auth().currentUser?.email {
            
            if tubeIsComing {  //tube is coming (set to true)
                
                tubeIsComing = false
                callTuber.setTitle("Get Tube", for: .normal)
                
                //remove query from database based on email
                Database.database().reference().child("TubeRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded,
                    with: { (snapshot) in
                    snapshot.ref.removeValue()
                    
                    //allows queries to stay when request is called until cancelled
                    Database.database().reference().child("TubeRequests").removeAllObservers()
                        
                        
                })
                
            } else {
                let tubeRequestDictionary : [String:Any] = ["email": email, "lat": userLocation.latitude, "lon": userLocation.longitude]
                Database.database().reference().child("TubeRequests").childByAutoId().setValue(tubeRequestDictionary)
                
                tubeIsComing = true
                callTuber.setTitle("Cancel Your Tube", for: .normal)
            }
            
            
        }
        }
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        
        //log out and go back to login page through navigation controller
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
        
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
