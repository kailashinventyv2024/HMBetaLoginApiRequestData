//
//  APIManager.swift
//  HMBetaLoginApiRequestData
//
//  Created by Kailash Rajput on 25/02/25.
//

import Foundation

enum HTTPMethodType: String{
    case GET
    case POST
    case DELETE
    case PUT
    case PATCH
}

enum APIError: Error{
    case InvalidResponse
    case InvalidData
    case FailedToDecodeData
    case InvalidCredentials
    case InvalidRequest
}

final class APIManager{
    static let shared = APIManager()
    private init(){}
    
    public func loginUser(loginModel: LoginRequestModel, completion: @escaping (Result<LoginResponseModel, Error>) -> Void){
        guard var request = createRequest(with: URL(string: "<Login API>"), type: .POST) else {
            completion(.failure(APIError.InvalidRequest))
            return
        }
        do{
            let encoder = JSONEncoder()
            let encodeBody = try encoder.encode(loginModel)
            request.httpBody = encodeBody
        }catch {
            completion(.failure(APIError.InvalidRequest))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error{
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.InvalidResponse))
                return
            }
            
            guard let data = data else{
                completion(.failure(APIError.InvalidData))
                return
            }
            
            do{
                let decoder = JSONDecoder()
                let result = try decoder.decode(LoginResponseModel.self, from: data)
                if result.isValidUser! == false{
                    completion(.failure(APIError.InvalidCredentials))
                    return
                }
                completion(.success(result))
            }catch let error{
                print(error)
                completion(.failure(APIError.FailedToDecodeData))
            }
        }
        task.resume()
        
    }
    
    private func createRequest(with url: URL?, type: HTTPMethodType) -> URLRequest?{
        guard let url = url else{
            return nil
        }
        var request = URLRequest(url: url);
        request.httpMethod = type.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
