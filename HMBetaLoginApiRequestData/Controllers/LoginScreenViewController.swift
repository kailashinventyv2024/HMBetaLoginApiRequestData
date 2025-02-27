//
//  LoginScreenViewController.swift
//  HMBetaLoginApiRequestData
//
//  Created by Kailash Rajput on 25/02/25.
//

import UIKit
import SQLite3

class LoginScreenViewController: UITableViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingSpinner.isHidden = true
    }
    
    @IBAction func onLoginBtnClick(_ sender: UIButton) {
        let email = emailField.text
        let password = passwordField.text
        
        guard let email = email, let password = password, email.isValidEmail else{
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Status", message: "Enter valid credetials", preferredStyle: .alert)
                
                let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(cancelBtn)
                
                self.present(alert, animated: true)
            }
            return
        }
        
        let loginModel = LoginRequestModel(userName: email, password: password, SoftwareType: "AN", ReleaseVersion: "049")
        loginBtn.isEnabled = false
        
        loadingSpinner.isHidden = false
        APIManager.shared.loginUser(loginModel: loginModel) { [weak self] result in
            DispatchQueue.main.async {
                self?.loginBtn.isEnabled = true
                self?.loadingSpinner.isHidden = true
            }
            switch result{
            case .success(let response):
                self?.handleSuccess(response: response)
            case .failure(let error):
                print(error)
                self?.handleFailure()
            }
        }
    }
    
    private func handleSuccess(response: LoginResponseModel) {
        DispatchQueue.main.async {
            if let userDetailsViewController = self.storyboard?.instantiateViewController(identifier: "UserDetailsViewController") as? UserDetailsViewController {
                userDetailsViewController.title = ""
                userDetailsViewController.firstName = response.firstName
                userDetailsViewController.lastName = response.lastName
                let gender = response.gender == 1 ? "Male" : "Female"
                userDetailsViewController.gender = gender
                userDetailsViewController.height = Double(response.heightCM ?? 0)
                userDetailsViewController.dob = response.dob

                self.navigationController?.setViewControllers([userDetailsViewController], animated: true)
            }
        }
    }
    
    private func handleFailure() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Status", message: "Login Failed", preferredStyle: .alert)
            
            let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(cancelBtn)
            
            self.present(alert, animated: true)
        }
        
    }
}


extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
}
