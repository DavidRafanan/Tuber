//
//  tuberViewController.swift
//  
//
//  Created by David Rafanan on 4/19/19.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class tuberViewController: UITableViewController, CLLocationManagerDelegate {

    var tubeRequests : [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var tuberLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    Database.database().reference().child("tubeRequests").observe(.childAdded) { (snapshot) in
        if let tubeRequestDictionary = snapshot.value as? [String:AnyObject] {
            if let tuberLat = tubeRequestDictionary["tuberLat"] as? Double {
            } else {
                self.tubeRequests.append(snapshot)
                self.tableView.reloadData()
            }
        }
    }
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
             self.tableView.reloadData() }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            tuberLocation = coord
        }
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tubeRequests.count
    }

    @IBAction func logoutTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tubeRequestCell", for: indexPath)
        
        let snapshot = tubeRequests[indexPath.row]
        
        if let tubeRequestDictionary = snapshot.value as? [String:AnyObject] {
            
            if let email = tubeRequestDictionary["email"] as? String {
                
                if let lat = tubeRequestDictionary["lat"] as? Double {
                    
                    if let lon = tubeRequestDictionary["lon"] as? Double {
                        
                        let tuberCLLocation = CLLocation(latitude: tuberLocation.latitude, longitude: tuberLocation.longitude)
                        
                        let tubingCLLocation = CLLocation(latitude: lat, longitude: lon)
                        
                        let distance = tuberCLLocation.distance(from: tubingCLLocation) / 1000
                        
                        let roundedDistance = round(distance * 100) / 100
                        
                        cell.textLabel?.text = "\(email) - \(roundedDistance)km away"
                        
                    }
                    
                }
                
            }
            
        }
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = tubeRequests[indexPath.row]
        performSegue(withIdentifier: "acceptSegue", sender: snapshot)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptVC = segue.destination as? acceptRequestViewController {
            
            if let snapshot = sender as? DataSnapshot {
                if let tubeRequestDictionary = snapshot.value as? [String:AnyObject] {
                    
                    if let email = tubeRequestDictionary["email"] as? String {
                        
                        if let lat = tubeRequestDictionary["lat"] as? Double {
                            
                            if let lon = tubeRequestDictionary["lon"] as? Double {
                                    acceptVC.requestEmail = email
                                
                                    let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                
                                    acceptVC.requestLocation = location
                                    acceptVC.tuberLocation = tuberLocation
                            }
                        }
                    }
                }
            }
        }
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
