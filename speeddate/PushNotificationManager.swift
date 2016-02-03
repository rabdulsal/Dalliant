//
//  PushNotificationManager.swift
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 2/3/16.
//  Copyright © 2016 Studio76. All rights reserved.
//

import Foundation

@objc class PushNotificationManager: NSObject {
    
    init(matchName: String, matchId: String, installationId: String, requestId: String) {
        
    }
    
    func sendShareRequestPushNotificationToUser(
        userNickname: String,
        withInstallationId installId: String,
        andRequestId requestId: String,
        completion:((succeeded: Bool, error: NSError?) -> Void)) {
            
            let query = PFInstallation.query()
            query?.whereKey("objectId", equalTo: installId)
            //[query whereKey:@"objectId" equalTo:matchUser.installation.objectId];
            
            let notificationData = [
                "alert" : "Request to Share Identities",
                "match" : userNickname,
                "requestId" : requestId,
                "badge" : "Increment",
                "sound" : "Ache.caf"
            ]
            
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
    
    func sendShareRequestReplyPushNotification(userNickname: String,
        withInstallationId installId: String,
        andRequestId requestId: String,
        completion:((succeeded: Bool, error: NSError?) -> Void)) {
            let query = PFInstallation.query()
            query?.whereKey("objectId", equalTo: installId)
            
            let notificationData = [
                "alert" : "Identity Share Reply",
                "requestId" : requestId,
                "badge" : "Increment",
                "sound" : "Ache.caf"
            ]
            
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
