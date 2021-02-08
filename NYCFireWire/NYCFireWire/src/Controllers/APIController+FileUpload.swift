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
let UploadVideoFileType = "video/mp4"
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
    
    private func createImageUrl(fileName: String, fileType: String, completion: @escaping(_ success: Bool, _ error: APIConstants.Error?, _ data: [String:Any]?) -> Void) {
        let url = APIConstants.construct(endpoint: .fileSignEndpoint)
        let data = [APIConstants.Keys.fileName:fileName, APIConstants.Keys.fileType:fileType]
        makeRequest(type: .get, url: url, parameters: data, completion: completion)
    }
    
    private func uploadImage(image: UIImage, readOnlyURL: String, preSignedURL: String, session: URLSession, completion: @escaping(_ success: Bool, _ imageURL: String?) -> Void) {
        let image = image.cropped
        if let imageData = image.jpeg(.medium), let url = URL(string: preSignedURL) {
            uploadFileWith(session: session, data: imageData, contentType: UploadFileType, using: url) { (success) in
                completion(success,String(readOnlyURL))
            }
        } else {
            completion(false,nil)
        }
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
    
    
    
    /*func uploadVideo(videoUrl: URL, completion: @escaping(_ success: Bool, _ imageURL: String?) -> Void) {
        
        guard let email = email, let token = token else {
            return
        }
        
        let fileName = Date().showInFormat(format: UploadFileNameFormat)
        let urlvideo = APIConstants.construct(endpoint: .fileSignEndpoint)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            do {
                let videoData = try Data(contentsOf: videoUrl)
                multipartFormData.append(videoData, withName: "video", fileName: "\(fileName).mp4", mimeType: "video/mp4")
                /*let data = [APIConstants.Keys.fileName:"video", APIConstants.Keys.fileType:"video/mp4"]
                    for (key, value) in data {
                        multipartFormData.append(value.data(using: .utf8)!, withName: key)
                    }*/
            } catch {
                debugPrint("Couldn't get Data from URL: \(videoUrl): \(error)")
            }
        }, to: urlvideo, method: .put) { (result) in
            print(result)
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    print("Uploading \(progress)")
                })
                .responseString(completionHandler: { (response) in
                    print("response status code \(response.response?.statusCode)")
                    print("response \(response.result)")
                })
                break
            case .failure(let encodingError):
                print("err is \(encodingError)")
                break
            }
        }
        
        /*let credentialData = "\(email):\(token)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        Alamofire.upload(multipartFormData: { (MultipartFormData) in
            do {
                let videoData = try Data(contentsOf: videoUrl)
                MultipartFormData.append(videoData, withName: "video", fileName: fileName, mimeType: "video/mp4")
                let data = [APIConstants.Keys.fileName:"video", APIConstants.Keys.fileType:"video/mp4"]
                    for (key, value) in data {
                        MultipartFormData.append(value.data(using: .utf8)!, withName: key)
                    }
            } catch {
                debugPrint("Couldn't get Data from URL: \(videoUrl): \(error)")
            }
        }, to: urlvideo, method: .get, headers: headers) { (result) in
            print(result)
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    print("Uploading \(progress)")
                })
                .responseString(completionHandler: { (response) in
                    print("response status code \(response.response?.statusCode)")
                    print("response \(response.result)")
                })
                break
            case .failure(let encodingError):
                print("err is \(encodingError)")
                break
            }
        }*/
    }*/
    
    private func uploadVideo(image: URL, readOnlyURL: String, preSignedURL: String, session: URLSession, completion: @escaping(_ success: Bool, _ imageURL: String?) -> Void) {
        do{
            let videoData = try Data(contentsOf: image)
            if let url = URL(string: preSignedURL) {
                uploadFileWith(session: session, data: videoData, contentType: UploadVideoFileType, using: url) { (success) in
                    completion(success,String(readOnlyURL))
                }
            } else {
                completion(false,nil)
            }
        }catch( let error){
            print("error \(error.localizedDescription)")
        }
    }
    
    func uploadVideo(image: URL, session: URLSession, completion: @escaping(_ success: Bool, _ imageURL: String?) -> Void) {
        let fileName = Date().showInFormat(format: UploadFileNameFormat)
        createVideoUrl(fileName: fileName, fileType: UploadVideoFileType) { (success, error, data) in
            let request = self.requestImageUrl(data: data)
            if let data = request {
                print("url: \(data.url) - signedRes: \(data.signedRes)")
                self.uploadVideo(image: image, readOnlyURL: data.url, preSignedURL: data.signedRes, session: session, completion: completion)
            }
        }
    }
    
    private func createVideoUrl(fileName: String, fileType: String, completion: @escaping(_ success: Bool, _ error: APIConstants.Error?, _ data: [String:Any]?) -> Void) {
        let url = APIConstants.construct(endpoint: .fileSignEndpoint)
        let data = [APIConstants.Keys.fileName:fileName, APIConstants.Keys.fileType:fileType]
        makeRequest(type: .get, url: url, parameters: data, completion: completion)
    }
}
