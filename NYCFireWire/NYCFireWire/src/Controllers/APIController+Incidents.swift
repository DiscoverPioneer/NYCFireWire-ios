//
//  APIController+Incidents.swift
//  LIAlerts
//
//  Created by Phil Scarfi on 9/17/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation
import CoreLocation

extension APIController {
    
//    SELECT incident.id, (case when exists (SELECT id FROM incident_like WHERE incident = incident.id AND _user=1) then 1 else 0 end) AS LIKED, CAST((SELECT COALESCE(COUNT(*),0) FROM incident_like WHERE incident_like.incident = incident.id) AS INTEGER) AS number_of_likes, CAST((SELECT COALESCE(COUNT(*),0) FROM comment WHERE comment.incident = incident.id) AS INTEGER) AS number_of_comments, CAST((SELECT COALESCE(views.total,0) FROM views WHERE views.incident = incident.id) AS INTEGER) AS total_views FROM incident WHERE boro <> 'Long Island' AND boro <> 'Outside NYC' ORDER BY created_at DESC LIMIT 40
    
    func getAllIncidents(feedType: String = "all", completion: @escaping (_ incidents: [Incident]) -> Void) {
        var allIncidents = [Incident]()
        let url = APIConstants.construct(endpoint: .allIncidentsEndpoint)
        makeRequest(type: .get, url: url, parameters: ["feed_type":feedType.lowercased()]) { (success, error, data) in
//            print("Incident data: \(data)")
            if let data = data,
                let incidents = data["result"] as? [[String:Any?]] {
                for rawIncident in incidents {
                    if let incident = Incident(dict: rawIncident) {
                        allIncidents.append(incident)
                    }
                }
            }
            completion(allIncidents)
        }
    }
    
    func getIncidentDetails(id: Int, completion:@escaping (_ incident: Incident?, _ comments: [Comment], _ adminComments: [Comment]) -> Void) {
        var comments = [Comment]()
        var adminComments = [Comment]()
        
        let url = APIConstants.construct(endpoint: .incidentDetailsEndpoint)
        let params = ["id":id]
        makeRequest(type: .get, url: url, parameters: params) { (success, error, data) in
            if let data = data,
                let rawIncident = data["incident"] as? [String:Any?], let incident = Incident(dict: rawIncident),
                let rawComments = data["comments"] as? [[String:Any?]], let rawAdminComments = data["admin_comments"] as? [[String:Any?]] {
                for c in rawComments {
                    if let comment = Comment(dict: c) {
                        comments.append(comment)
                    }
                }
                
                for ac in rawAdminComments {
                    if let comment = Comment(dict: ac) {
                        adminComments.append(comment)
                    }
                }
                completion(incident,comments,adminComments)
            } else {
                completion(nil,comments,adminComments)
            }
        }
    }
    
    func postCommentFor(location: Location, comment: String,imageURL: String? = nil, completion:@escaping (_ comment: Comment?) -> Void) {
        let url: String
        if location is Incident {
            url = APIConstants.construct(endpoint: "/incident/\(location.id)/comment")
        } else {
            url = APIConstants.construct(endpoint: "/incident-inquiry/\(location.id)/comment")
        }
        let params: [String:String]
        if let imageURL = imageURL {
            params = ["comment":comment,"image_url":imageURL]
        } else {
            params = ["comment":comment]
        }
        makeRequest(type: .post, url: url, parameters: params) { (success, error, data) in
            if let rawComment = data?["result"] as? [String:Any?] {
                completion(Comment(dict: rawComment))
                return
            }
            completion(nil)
        }
    }
    
    func postCommentVideoFor(location: Location, comment: String,imageURL: String? = nil,videoURL: String? = nil, completion:@escaping (_ comment: Comment?) -> Void) {
        let url: String
        if location is Incident {
            url = APIConstants.construct(endpoint: "/incident/\(location.id)/comment")
        } else {
            url = APIConstants.construct(endpoint: "/incident-inquiry/\(location.id)/comment")
        }
        let params: [String:String]
        if let videoURL = videoURL, let imgURL = imageURL{
            params = ["comment":comment,"video_url":videoURL, "image_url":imgURL]
        } else {
            params = ["comment":comment]
        }
        makeRequest(type: .post, url: url, parameters: params) { (success, error, data) in
            if let rawComment = data?["result"] as? [String:Any?] {
                completion(Comment(dict: rawComment))
                return
            }
            completion(nil)
        }
    }
    
    func createIncidentWithParams(params: [String:Any], completion:@escaping (_ success: Bool) -> Void) {
        let url = APIConstants.construct(endpoint: .createIncidentEndpoint)
        makeRequest(type: .post, url: url, parameters: params) { (success, error, data) in
            if let _ = data {
                completion(true)
                return
            }
            completion(false)
        }
    }
    
    func createTipWithParams(params: [String:Any], completion:@escaping (_ success: Bool) -> Void) {
        let url = APIConstants.construct(endpoint: .createTipEndpoint)
        makeRequest(type: .post, url: url, parameters: params) { (success, error, data) in
            if let _ = data {
                completion(true)
                return
            }
            completion(false)
        }
    }
    
    func setFeaturedImage(imageURL: URL?, id: Int, completion:@escaping (_ success: Bool) -> Void) {
        var url = APIConstants.construct(endpoint: .incidentDetailsEndpoint)
        url.append("\(id)/set-featured-image")
        let params = ["image_url":imageURL]
        makeRequest(type: .post, url: url, parameters: params) { (success, error, data) in
            if let _ = data {
                completion(success)
                return
            }
            completion(false)
        }
    }
    
    func acknowledgeIncident(id: Int, completion:@escaping (_ success: Bool) -> Void) {
        var url = APIConstants.construct(endpoint: .incidentDetailsEndpoint)
        url.append("\(id)/acknowledge")
        makeRequest(type: .post, url: url, parameters: nil) { (success, error, data) in
            if let _ = data {
                completion(true)
                return
            }
            completion(false)
        }
    }
    
    func likeIncident(id: Int, completion:@escaping (_ success: Bool) -> Void) {
        var url = APIConstants.construct(endpoint: .incidentDetailsEndpoint)
        url.append("\(id)/like")
        makeRequest(type: .post, url: url, parameters: nil) { (success, error, data) in
            if let _ = data {
                completion(true)
                return
            }
            completion(false)
        }
    }
    
    func unlikeIncident(id: Int, completion:@escaping (_ success: Bool) -> Void) {
        var url = APIConstants.construct(endpoint: .incidentDetailsEndpoint)
        url.append("\(id)/unlike")
        makeRequest(type: .post, url: url, parameters: nil) { (success, error, data) in
            if let _ = data {
                completion(true)
                return
            }
            completion(false)
        }
    }
    
    func updateViewsCountForLocation(location: Incident) {
        let url = APIConstants.construct(endpoint: .updateIncidentViewsCountEndpoint)
        let params = ["id":location.id]
        makeRequest(type: .post, url: url, parameters: params) { (success, error, data) in
            print("Updated View Count: \(success)")
        }
    }
}



