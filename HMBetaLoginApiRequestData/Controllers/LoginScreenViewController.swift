//
//  LoginScreenViewController.swift
//  HMBetaLoginApiRequestData
//
//  Created by Kailash Rajput on 25/02/25.
//

import UIKit

class LoginScreenViewController: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var spinnerLoading: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinnerLoading.isHidden = true
    }
    
    @IBAction func onbtnLoginClick(_ sender: UIButton) {
        let email = txtEmail.text
        let password = txtPassword.text
        
        guard let email = email, let password = password, email.isValidEmail, !password.isEmpty else{
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Status", message: "Enter valid email and password", preferredStyle: .alert)
                
                let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(cancelBtn)
                
                self.present(alert, animated: true)
            }
            return
        }
        
        let loginModel = LoginRequestModel(
            userName: email,
            password: password,
            SoftwareType: "AN",
            ReleaseVersion: "049"
        )
        btnLogin.isEnabled = false
        
        spinnerLoading.isHidden = false
        APIManager.shared.loginUser(loginModel: loginModel) { [weak self] result in
            DispatchQueue.main.async {
                self?.btnLogin.isEnabled = true
                self?.spinnerLoading.isHidden = true
            }
            switch result{
            case .success(let response):
                self?.handleSuccess(response: response)
            case .failure(let error):
                print(error)
                self?.handleFailure(error)
            }
        }
    }
    
    private func handleSuccess(response: LoginResponseModel) {
        let userDetails = UserDetails(
            firstName: response.firstName ?? "",
            email: response.email ?? "",
            lastName: response.lastName ?? "",
            gender: response.gender == 1 ? "Male" : "Female",
            dateOfBirth: response.dob ?? "",
            height: Double(response.heightCM ?? 0)
        )

        if DatabaseHelper.shared.fetchByEmailId(email: userDetails.email) == nil {
            if DatabaseHelper.shared.insertUser(userDetail: userDetails) {
                UserDefaults.standard.setValue(userDetails.email, forKey: "email")
            }
            navigateToUserDetails()
        } else {
            let alert = UIAlertController(
                title: "Message",
                message: "User already exists. Do you want to override it?",
                preferredStyle: .alert
            )

            let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                UserDefaults.standard.setValue(userDetails.email, forKey: "email")
                self.navigateToUserDetails()
            }

            let yesBtn = UIAlertAction(title: "Yes", style: .default) { _ in
                if DatabaseHelper.shared.updateUser(userDetail: userDetails) {
                    UserDefaults.standard.setValue(userDetails.email, forKey: "email")
                }
                self.navigateToUserDetails()
            }

            alert.addAction(cancelBtn)
            alert.addAction(yesBtn)
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
    }

    private func navigateToUserDetails() {
        DispatchQueue.main.async {
            if let userDetailsViewController = self.storyboard?.instantiateViewController(identifier: "UserDetailsViewController") as? UserDetailsViewController {
                userDetailsViewController.title = ""
                self.navigationController?.setViewControllers([userDetailsViewController], animated: true)
            }
        }
    }

    
    
    private func handleFailure(_ error: Error) {
        print(error)
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
