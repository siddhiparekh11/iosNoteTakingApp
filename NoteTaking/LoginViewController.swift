//
//  LoginViewController.swift
//  NoteTaking
//
//  Created by Siddhi Parekh on 9/15/18.
//  Copyright © 2018 Siddhi Parekh. All rights reserved.
//

// This page is the initial Login screen of the app where the user enters his name and moves forward

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var unameTextView: UITextField?
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.unameTextView?.addBottomBorder(red:242.0,green:141.0,blue:115.0)
        // The below statement is responsible for setting the textview placeholder text color
        unameTextView?.attributedPlaceholder =
            NSAttributedString(string: "Enter Your Name", attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(red: 242.0/255.0, green: 141.0/255.0, blue: 115.0/255.0, alpha: 1)])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // This method stop the Login screen from going forward if user hasn't enter his identity - name
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "logintoview") {
            if (unameTextView?.text==""){
                createAlert()
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "logintoview"){
            let notesViewController:NotesViewController = segue.destination as! NotesViewController
            notesViewController.userName = (unameTextView?.text)!
        }
    }
    
    func createAlert(){
        let alert = UIAlertController(title: "Error!", message: "Please enter the username to move forward.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
           
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

// This extension is used for removing the borders except for the bottom border and set its color
extension UITextField {
    func addBottomBorder(red:Float,green:Float,blue:Float){
        let bottomLine = CALayer()
        bottomLine.frame = CGRect.init(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
        bottomLine.backgroundColor = UIColor.init(red: CGFloat(red/255.0), green: CGFloat(green/255.0), blue: CGFloat(blue/255.0), alpha: 1).cgColor
        self.borderStyle = UITextBorderStyle.none
        self.layer.addSublayer(bottomLine)
    }
}
