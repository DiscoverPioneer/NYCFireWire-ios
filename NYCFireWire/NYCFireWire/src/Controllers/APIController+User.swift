//
//  APIController+User.swift
//  LIAlerts
//
//  Created by Phil Scarfi on 10/1/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation
import Alamofire

extension APIController {
    
    fileprivate func makeAuthRequest(url: String, data: [String:Any?]?, completion: @escaping (_ user: FullUser?, _ errorMessage: String?) -> Void) {
        makeNonTokenRequest(type: .post, url: url, parameters: data) { (success, error, data) in
            if let data = data, let rawUser = data["user"] as? [String:Any?], let parsedUser = FullUser(dict: rawUser), let token = (data["token"] as? [String:Any?])?["token"] as? String {
                UserDefaultConstants.setObjectForKey(key: .userTokenKey, value: token)
                UserDefaultConstants.setObjectForKey(key: .userEmailKey, value: parsedUser.email)
                completion(parsedUser, data["error"] as? String)
                return
            }
            completion(nil, data?["error"] as? String)
        }
    }
    
    func signin(email: String, password: String, completion: @escaping (_ user: FullUser?, _ errorMessage: String?) -> Void) {
        let url = APIConstants.construct(endpoint: .signinEndpoint)
        let data = ["email":email,"password":password]
        makeAuthRequest(url: url, data: data, completion: completion)
    }
    
    func resetPassword(email: String, completion: @escaping () -> Void) {
        let url = APIConstants.construct(endpoint: .resetPasswordEndpoint)
        makeNonTokenRequest(type: .post, url: url, parameters: ["email":email]) { (success, error, data) in
            completion()
        }
    }
    
    func signup(email: String, password: String, firstName: String, lastName: String, phoneNumber: String?, rank: String?, completion: @escaping (_ user: FullUser?, _ errorMessage: String?) -> Void) {
        let url = APIConstants.construct(endpoint: .signupEndpoint)
        var data = [
            "email":email,
            "password":password,
            "first_name":firstName,
            "last_name":lastName
        ]
        if let phoneNumber = phoneNumber {
            data["phone_number"] = phoneNumber
        }
        if let rank = rank {
            data["rank"] = rank
        }
        makeAuthRequest(url: url, data: data, completion: completion)
    }
    
    func getMe(completion: @escaping (_ user: FullUser?) -> Void) {
        let url = APIConstants.construct(endpoint: .meEndpoint)
        makeRequest(type: .get, url: url, parameters: nil) { (success, error, data) in
            if let data = data, let rawUser = data["result"] as? [String:Any?] {
                completion(FullUser(dict: rawUser))
                return
            }
            completion(nil)
        }
    }
    
    func verifyUser(email: String, completion: @escaping (_ success: Bool) -> Void) {
        let url = APIConstants.construct(endpoint: .verifyEndpoint)
        makeRequest(type: .post, url: url, parameters: nil) { (success, error, data) in
            completion(success)
        }
    }
    
    func updateUser(updateDict: [String:Any],completion: @escaping (_ user: FullUser?) -> Void) {
        let url = APIConstants.construct(endpoint: .updateUserEndpoint)
        let params = ["update_dict":updateDict]
        makeRequest(type: .post, url: url, parameters: params) { (success, error, data) in
            if let data = data, let rawUser = data["user"] as? [String:Any?], let user = FullUser(dict: rawUser) {
                print("UPDATED USER!")
                AppManager.shared.currentUser = user
                UserDefaultConstants.setObjectForKey(key: .userEmailKey, value: user.email)
            }
        }
    }
    
    func blockUser(userID: Int) {
        let url = APIConstants.construct(endpoint: .blockUserEndpoint)
        let params = ["user":userID]
        makeRequest(type: .post, url: url, parameters: params) { (success, error, data) in
            print("Blocked user")
        }
    }
    
    func setFeaturedImage(imageURL: URL?, id: Int, completion: @escaping (_ error: String?) -> Void) {
        let url = APIConstants.baseURL + "/incident/\(id)/set-featured-image"
        let params = ["image_url":imageURL]
        makeRequest(type: .post, url: url, parameters: params) { (success, error, data) in
            if let error = error {
                completion(error.message)
            }
        }
    }
    
    func logout() {
        let url = APIConstants.construct(endpoint: .logoutEndpoint)
        makeRequest(type: .post, url: url, parameters: nil) { (success, error, data) in
        }
        UserDefaultConstants.setObjectForKey(key: .userTokenKey, value: nil)
        UserDefaultConstants.setObjectForKey(key: .userEmailKey, value: nil)
    }
}
