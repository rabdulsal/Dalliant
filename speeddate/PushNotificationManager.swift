//
//  PushNotificationManager.swift
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 2/3/16.
//  Copyright © 2016 Studio76. All rights reserved.
//

import Foundation

@objc class PushNotificationManager : NSObject {
    
    let matchName: String!
    let matchId: String!
    let requestId: String!
    let installationId: String!
    let requestType: RequestType!
    
    @objc enum RequestType : Int {
        case ShareRequest
        case ShareReply
    }
    
    init(matchName: String,
        matchId: String,
        installationId: String,
        requestId: String,
        requestType: RequestType) {
        self.matchName      = matchName
        self.matchId        = matchId
        self.installationId = installationId
        self.requestId      = requestId
        self.requestType    = requestType
    }
    
    @objc func sendShareRequestPushNotificationToUser(completion:((succeeded: Bool, error: NSError?) -> Void)) {
    
        var notificationData = [
            "match"     : matchName,
            "requestId" : requestId,
            "badge"     : "Increment",
            "sound"     : "Ache.caf"
        ]
        
        switch self.requestType! {
            case .ShareRequest: notificationData["alert"] = "Request to Share Identities"
            case .ShareReply: notificationData["alert"]   = "Identity Share Reply"
        }
        
        let query = PFInstallation.query()
        query?.whereKey("objectId", equalTo: installationId)
        
        let push = PFPush()
        push.setQuery(query)
        push.setData(notificationData)
        push.sendPushInBackgroundWithBlock { (success, error) -> Void in
            if success {
                completion(succeeded: success, error: nil)
            } else {
                completion(succeeded: false, error: error)
            }
        }
    }
    
}
