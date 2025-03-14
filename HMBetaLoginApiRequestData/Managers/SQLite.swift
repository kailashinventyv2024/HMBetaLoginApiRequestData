//
//  SQLite.swift
//  HMBetaLoginApiRequestData
//
//  Created by Kailash Rajput on 25/02/25.
//
import SQLite3
import Foundation

final class DatabaseHelper {
    private var db: OpaquePointer?
    static let shared = DatabaseHelper()
    
    private init() {
        openDatabase()
    }
    
    func openDatabase() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = documentsDirectory.appendingPathComponent("hmBetaLogin.sqlite").path
        
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("Successfully opened database at \(dbPath)")
            createTable()
        } else {
            print("Failed to open database")
        }
    }
    
    func createTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS Users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT,
            last_name TEXT,
            email TEXT UNIQUE,
            gender TEXT,
            date_of_birth TEXT,
            height REAL
        );
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableQuery, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Table created successfully")
            } else {
                print("Failed to create table")
            }
        } else {
            print("Failed to prepare table creation statement")
        }
        
        sqlite3_finalize(statement)
    }
    
    func insertUser(userDetail: UserDetails) -> Bool {
        let insertQuery = "INSERT INTO Users (first_name, last_name, email, gender, date_of_birth, height) VALUES (?, ?, ?, ?, ?, ?);"
        
        var statement: OpaquePointer?
        var success: Bool = false
        
        if sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK {
            let firstNameCString = userDetail.firstName.cString(using: .utf8)
            let lastNameCString = userDetail.lastName.cString(using: .utf8)
            let emailCString = userDetail.email.cString(using: .utf8)
            let genderCString = userDetail.gender.cString(using: .utf8)
            let dobCString = userDetail.dateOfBirth.cString(using: .utf8)
            
            sqlite3_bind_text(statement, 1, firstNameCString, -1, nil)
            sqlite3_bind_text(statement, 2, lastNameCString, -1, nil)
            sqlite3_bind_text(statement, 3, emailCString, -1, nil)
            sqlite3_bind_text(statement, 4, genderCString, -1, nil)
            sqlite3_bind_text(statement, 5, dobCString, -1, nil)
            sqlite3_bind_double(statement, 6, userDetail.height)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully inserted user: \(userDetail.firstName)")
                success = true
            } else {
                print("Failed to insert user. Email might already exist.")
            }
        } else {
            print("Failed to prepare statement")
        }
        
        sqlite3_finalize(statement)
        return success
    }
    
    func updateUser(userDetail: UserDetails) -> Bool {
        let updateQuery = """
        UPDATE Users SET first_name = ?, last_name = ?, gender = ?, date_of_birth = ?, height = ? 
        WHERE email = ?;
        """
        
        var statement: OpaquePointer?
        var success: Bool = false
        
        if sqlite3_prepare_v2(db, updateQuery, -1, &statement, nil) == SQLITE_OK {
            let firstNameCString = userDetail.firstName.cString(using: .utf8)
            let lastNameCString = userDetail.lastName.cString(using: .utf8)
            let genderCString = userDetail.gender.cString(using: .utf8)
            let dobCString = userDetail.dateOfBirth.cString(using: .utf8)
            let emailCString = userDetail.email.cString(using: .utf8)
            
            sqlite3_bind_text(statement, 1, firstNameCString, -1, nil)
            sqlite3_bind_text(statement, 2, lastNameCString, -1, nil)
            sqlite3_bind_text(statement, 3, genderCString, -1, nil)
            sqlite3_bind_text(statement, 4, dobCString, -1, nil)
            sqlite3_bind_double(statement, 5, userDetail.height)
            sqlite3_bind_text(statement, 6, emailCString, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully updated user with email: \(userDetail.email)")
                success = true
            } else {
                print("Failed to update user")
            }
        } else {
            print("Failed to prepare statement")
        }
        
        sqlite3_finalize(statement)
        return success
    }
    
    func fetchByEmailId(email: String) -> UserDetails? {
        let query = "SELECT first_name, last_name, email, gender, date_of_birth, height FROM Users WHERE email = ? LIMIT 1;"
        var statement: OpaquePointer?
        var userDetails: UserDetails?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            let emailCString = email.cString(using: .utf8)
            sqlite3_bind_text(statement, 1, emailCString, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let firstName = String(cString: sqlite3_column_text(statement, 0))
                let lastName = String(cString: sqlite3_column_text(statement, 1))
                let email = String(cString: sqlite3_column_text(statement, 2))
                let gender = String(cString: sqlite3_column_text(statement, 3))
                let dob = String(cString: sqlite3_column_text(statement, 4))
                let height = sqlite3_column_double(statement, 5)
                
                userDetails = UserDetails(firstName: firstName, email: email, lastName: lastName, gender: gender, dateOfBirth: dob, height: height)
                print("User found: \(userDetails!)")
            } else {
                print("No user found with email: \(email)")
            }
        } else {
            print("Failed to prepare statement")
        }
        
        sqlite3_finalize(statement)
        return userDetails
    }
    
    func fetchAllUsers() {
        let query = "SELECT * FROM Users;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int(statement, 0)
                let firstName = String(cString: sqlite3_column_text(statement, 1))
                let lastName = String(cString: sqlite3_column_text(statement, 2))
                let email = String(cString: sqlite3_column_text(statement, 3))
                let gender = String(cString: sqlite3_column_text(statement, 4))
                let dob = String(cString: sqlite3_column_text(statement, 5))
                let height = sqlite3_column_double(statement, 6)
                
                print("ID: \(id), Name: \(firstName) \(lastName), Email: \(email), Gender: \(gender), DOB: \(dob), Height: \(height)")
            }
        } else {
            print("Failed to fetch users")
        }
        
        sqlite3_finalize(statement)
    }
}
