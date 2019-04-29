//
//  ViewController.swift
//  Tuber
//
//  Created by David Rafanan on 4/18/19.
//  Copyright © 2019 David Rafanan. All rights reserved.
//Users/davidrafanan/Projects/Tuber/Tuber/Base.lproj/Main.storyboard//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var tuberLabel: UILabel!
    @IBOutlet weak var tubingLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var tubeSwitch: UISwitch!
    @IBOutlet weak var signUpTop: UIButton!
    @IBOutlet weak var logInBottom: UIButton!
    
    var signUp = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func signUpTapped(_ sender: Any) {
        if emailTextField.text == "" || passwordTextField.text == "" {  //if empty field texts
            displayAlert(title: "Missing Information", message: "Please provide email and password")
        } else {
                if let email = emailTextField.text {
                    if let password = passwordTextField.text {
                        if signUp {
                            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                                if error != nil {  //error
                                    self.displayAlert(title: "Error", message: error!.localizedDescription)
                                }
                                else {
                                    
                                    if self.tubeSwitch.isOn { //tubing
                                        let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                        req?.displayName = "Tubing"
                                        req?.commitChanges(completion: nil)
                                        self.performSegue(withIdentifier: "tubingSegue", sender: nil)
                                    } else { //tuber
                                        let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                        req?.displayName = "Tuber"
                                        req?.commitChanges(completion: nil)
                                        self.performSegue(withIdentifier: "tuberSegue", sender: nil)
                                    }
                                    
                                    
                                }
                            })
                        }
                        else {   //log in mode
                            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                                if error != nil {  //error
                                    self.displayAlert(title: "Error", message: error!.localizedDescription)
                                }
                                else {
                                    if user?.user.displayName == "Tuber" {
                                        self.performSegue(withIdentifier: "tuberSegue", sender: nil)
                                    } else { //Tubing
                                        self.performSegue(withIdentifier: "tubingSegue", sender: nil)
                                    }
                                    
                                }
                            })
                        }
                    }
            }
        }
    }
    
    func displayAlert(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func logInTapped(_ sender: Any) {
        if signUp { //user already signed in, go to log in options
            signUpTop.setTitle("Log In", for: .normal)
            logInBottom.setTitle("Switch to Sign Up", for: .normal)
            tuberLabel.isHidden = true
            tubingLabel.isHidden = true
            tubeSwitch.isHidden = true
            signUp = false
            
        } else {   //if user didn't sign up yet, show sign up options
            signUpTop.setTitle("Sign Up", for: .normal)
            logInBottom.setTitle("Switch to Log In", for: .normal)
            tuberLabel.isHidden = false
            tubingLabel.isHidden = false
            tubeSwitch.isHidden = false
            signUp = true
        }
    }
}

