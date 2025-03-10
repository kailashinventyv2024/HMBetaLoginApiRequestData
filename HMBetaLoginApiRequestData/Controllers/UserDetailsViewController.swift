//
//  UserDetailsViewController.swift
//  HMBetaLoginApiRequestData
//
//  Created by Kailash Rajput on 25/02/25.
//

import UIKit

enum Gender: String {
    case Male = "Male"
    case Female = "Female"
}

class UserDetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var pickerDateOfBirth: UIDatePicker!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    @IBOutlet weak var pickerHeight: UIPickerView!
    
    private var selectedGender: Gender? = nil
    private var selectedHeight: Int = 0
    
    private var email: String? {
        return UserDefaults.standard.string(forKey: "email")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerHeight.delegate = self
        pickerHeight.dataSource = self
        fetchUserInfo()
    }
    
    private func fetchUserInfo() {
        let userInfo = DatabaseHelper.shared.fetchByEmailId(email: email ?? "")
        
        guard let userInfo = userInfo else { return }
        txtFirstName.text = userInfo.firstName
        txtLastName.text = userInfo.lastName
        
        if userInfo.gender == "Male" {
            selectedGender = .Male
            updateGenderButtons()
        } else if userInfo.gender == "Female" {
            selectedGender = .Female
            updateGenderButtons()
        }
        
        selectedHeight = Int(userInfo.height)
        pickerHeight.selectRow(selectedHeight, inComponent: 0, animated: false)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = dateFormatter.date(from: userInfo.dateOfBirth) {
            pickerDateOfBirth.date = date
        }
    }
    
    func formatDateToISO8601(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: date)
    }
    
    @IBAction func btnFemaleTapped(_ sender: UIButton) {
        selectedGender = .Female
        updateGenderButtons()
    }
    
    @IBAction func btnMaleTapped(_ sender: UIButton) {
        selectedGender = .Male
        updateGenderButtons()
    }
    
    func updateGenderButtons() {
        btnMale.setImage(
            UIImage(systemName: selectedGender == .Male ? "largecircle.fill.circle" : "circle"),
            for: .normal
        )
        btnFemale.setImage(
            UIImage(systemName: selectedGender == .Female ? "largecircle.fill.circle" : "circle"),
            for: .normal
        )
    }
    
    @IBAction func onbtnSaveClick(_ sender: UIButton) {
        guard let firstName = txtFirstName.text, !firstName.isEmpty,
              let lastName = txtLastName.text, !lastName.isEmpty,
              let gender = selectedGender?.rawValue else {
            let alert = UIAlertController(title: "Message", message: "Validation failed: Missing required fields", preferredStyle: .alert)
            let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(cancelBtn)
            self.present(alert, animated: true)
            return
        }
        
        let dob = pickerDateOfBirth.date
        let dobString = formatDateToISO8601(dob)
        
        let userDetails = UserDetails(
            firstName: firstName,
            email: email ?? "",
            lastName: lastName,
            gender: gender,
            dateOfBirth: dobString,
            height: Double(selectedHeight)
        )
        
        btnSave.setTitle("Saving...", for: .normal)
        
        if DatabaseHelper.shared.updateUser(userDetail: userDetails) {
            print("Success")
            handleSuccess()
            DatabaseHelper.shared.fetchAllUsers()
        }
    }
    
    private func handleSuccess() {
        DispatchQueue.main.async {
            self.btnSave.setTitle("Save", for: .normal)
            let alert = UIAlertController(title: "Status", message: "Your data saved successfully", preferredStyle: .alert)
            let cancelBtn = UIAlertAction(title: "OK", style: .default)
            alert.addAction(cancelBtn)
            self.present(alert, animated: true)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 301
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row) cm"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedHeight = row
    }
}
