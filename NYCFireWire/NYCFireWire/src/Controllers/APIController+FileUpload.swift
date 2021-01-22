//
//  APIController+FileUpload.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 10/11/19.
//  Copyright © 2019 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation
import UIKit

let UploadFileType = "image/jpeg"
let VideoUploadType = "video.mp4"
let UploadFileNameFormat = "MMMdyyyyhhmmssa"

extension APIController {
    
    func uploadImage(image: UIImage, session: URLSession, completion: @escaping(_ success: Bool, _ imageURL: String?) -> Void) {
        let fileName = Date().showInFormat(format: UploadFileNameFormat)

        createImageUrl(fileName: fileName, fileType: UploadFileType) { (success, error, data) in
            let request = self.requestImageUrl(data: data)
            if let data = request {
                print("url: \(data.url) - signedRes: \(data.signedRes)")
                self.uploadImage(image: image, readOnlyURL: data.url, preSignedURL: data.signedRes, session:session, completion: completion)
            }
        }
    }
    
    func uploadVideo(url: URL, session: URLSession, completion: @escaping(_ success: Bool, _ videoURL: String?) -> Void) {
        let fileName = Date().showInFormat(format: UploadFileNameFormat)

        createImageUrl(fileName: fileName, fileType: UploadFileType) { (success, error, data) in
            let request = self.requestImageUrl(data: data)
            if let data = request {
                print("url: \(data.url) - signedRes: \(data.signedRes)")
                self.uploadVideo(url: url, readOnlyURL: data.url, preSignedURL: data.signedRes, session:session, completion: completion)
            }
        }
    }
    

    private func createImageUrl(fileName: String, fileType: String, completion: @escaping(_ success: Bool, _ error: APIConstants.Error?, _ data: [String:Any]?) -> Void) {
        let url = APIConstants.construct(endpoint: .fileSignEndpoint)
        let data = [APIConstants.Keys.fileName:fileName, APIConstants.Keys.fileType:fileType]
        makeRequest(type: .get, url: url, parameters: data, completion: completion)
    }
    
    private func uploadImage(image: UIImage, readOnlyURL: String, preSignedURL: String, session: URLSession, completion: @escaping(_ success: Bool, _ imageURL: String?) -> Void) {
       
    }
    
    private func uploadVideo(url: URL, readOnlyURL: String, preSignedURL: String, session: URLSession, completion: @escaping(_ success: Bool, _ imageURL: String?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let unwrappedData = data else { return }
//        do {
//          let data = try Data(contentsOf: url)
            if let url = URL(string: preSignedURL) {
                self.uploadFileWith(session: session, data: unwrappedData, contentType: UploadFileType, using: url) { (success) in
                    completion(success,String(readOnlyURL))
                }
            } else {
                completion(false,nil)
            }
//        } catch {
//            print("error getting data")
//            completion(false,nil)
//        }
//       
    }
        task.resume()
    }
    private func requestImageUrl(data: [String:Any]?) -> (url: String, signedRes: String)? {
        if let res = data?["data"] as? [String:Any], let signedURL = res["signedRequest"] as? String, let readOnlyURL = res["url"] as? String {
            print("SignedURL: \(signedURL)\nReadOnlyURL:\(readOnlyURL)")
            print("res: \(res)")
            return (readOnlyURL, signedURL)
        }
        return nil
    }
    
    private func uploadFileWith(session: URLSession ,data: Data, contentType: String, using preSignedURL: URL, completion: @escaping(_ success: Bool) -> Void) {
        var request = URLRequest(url: preSignedURL)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        let uploadTask = session.uploadTask(with: request, from: data) { (data, response, error) in
//            print("Data: \(data)\nResponse:\(response)\nError:\(error)")
            completion(error == nil)
        }
        uploadTask.resume()
    }
}
