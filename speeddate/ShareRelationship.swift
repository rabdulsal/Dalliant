//
//  ShareRelationship.swift
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 12/20/15.
//  Copyright © 2015 Studio76. All rights reserved.
//

import Foundation

@objc class ShareRelationship : PFObject, PFSubclassing, IdentityRevealDelegate {
    
    @objc enum ShareState: Int {
        case NotSharing, Requested, Sharing, Rejected
    }
    
    @NSManaged var firstRequestedSharer: String
    @NSManaged var secondRequestedSharer: String
    @NSManaged var firstSharerShareState: Int
    @NSManaged var secondSharerShareState: Int
    
    let fSharer = "firstRequestedSharer", sSharer = "secondRequestedSharer"

    // Notificications
    let kRequestSentNotification     = "requestSentNotification"
    let kRequestAcceptedNotification = "requestAcceptedNotification"
    let kRequestRejectedNotification = "requestRejectedNotification"

    //MARK: Parse Initializers
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "ShareRelationship"
    }

    //MARK: Class Methods
    @objc class func fetchShareRelationshipBetween(currentUser: UserParseHelper, andMatch match: UserParseHelper, completion:((sharerelation: ShareRelationship?, error: NSError?) -> Void)) {
        if let query1 = ShareRelationship.query(), query2 = ShareRelationship.query() {
            query1.whereKey("firstRequestedSharer", equalTo: currentUser.nickname)
            query1.whereKey("secondRequestedSharer", equalTo: match.nickname)
            query2.whereKey("firstRequestedSharer", equalTo: match.nickname)
            query2.whereKey("secondRequestedSharer", equalTo: currentUser.nickname)
            
            let orQuery = PFQuery.orQueryWithSubqueries([query1,query2])
            orQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if (error == nil) {
                    if (objects?.count > 0) {
                        let relation = objects?.first as! ShareRelationship
                        completion(sharerelation: relation,error: nil)
                    } else {
                        completion(sharerelation: nil, error: nil)
                    }
                } else {
                    // TODO: Handle error
                }   
            })
        }
    }
    
    //MARK: Instance Methods
//    Method may not be needed
//    func userIsFirstSharer(currentUser: UserParseHelper, inShareRelationship shareRelation: ShareRelationship) -> Bool {
//        return currentUser.nickname == shareRelation.firstRequestedSharer
//    }
    // Get User ShareState
    func getCurrentUserShareState(currentUser: UserParseHelper) -> Int {
        if (currentUser.nickname == self.firstRequestedSharer) {
            return self.firstSharerShareState
        } else {
            return self.secondSharerShareState
        }
    }
    // Set User ShareState
    func setCurrentUser(currentUser: UserParseHelper, shareState: ShareState, forRelation shareRelationship: ShareRelationship, completion:((success: Bool, error: NSError?) -> Void)) {
        if currentUser.nickname == shareRelationship.firstRequestedSharer {
            shareRelationship.firstSharerShareState = shareState.rawValue
        } else {
            shareRelationship.secondSharerShareState = shareState.rawValue
        }
        
        shareRelationship.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
            if succeeded {
               //Set off Notification to update MessagesVC and ChatMessageVC UI
                completion(success: succeeded, error: nil)
            } else {
                completion(success: false, error: error)
            }
        })
    }
    
    //MARK: Protocol Methods
    func shareRequestSentFromUser(currentUser: UserParseHelper!, toMatch match: UserParseHelper!) {
        print("ShareRelationship protocol run!")
        //Fetch ShareRelationship from Parse based on first/secondRequestSharer
        /* Scenarios:
         * 
         * 1st & 2nd "UnShared"
         *
         * if cUser is 1stSh : relation.1stSh -> RQT
         *
        */
        ShareRelationship.fetchShareRelationshipBetween(currentUser, andMatch: match) { (sharerelation, error) -> Void in
            if error == nil {
                self.setCurrentUser(currentUser, shareState: .Requested, forRelation: sharerelation!, completion: { (success, error) -> Void in
                    if success {
                        //NSNotificationCenter.defaultCenter().postNotificationName(self.kRequestSentNotification, object: nil, userInfo:["article":self])
                        NSNotificationCenter.defaultCenter().postNotificationName(self.kRequestSentNotification, object: nil)
                    } else {
                        // Handle error
                    }
                })
            }
        }
        //Set first/secondSharerState
        // if cUser is 1stSh : relation.1stSh -> RQT
        
    }
    
    //Outgoing Actions
    func shareRequestFromMatch(match: UserParseHelper!, acceptedByUser currentUser: UserParseHelper!) {
        /*
        *   Fetch ShareRelation, set ShareState
        */
        ShareRelationship.fetchShareRelationshipBetween(currentUser, andMatch: match) { (sharerelation, error) -> Void in
            if error == nil {
                self.setCurrentUser(currentUser, shareState: .Sharing, forRelation: sharerelation!, completion: { (success, error) -> Void in
                    if success {
                        //NSNotificationCenter.defaultCenter().postNotificationName(self.kRequestAcceptedNotification, object: nil, userInfo: ["article":self])
                        NSNotificationCenter.defaultCenter().postNotificationName(self.kRequestAcceptedNotification, object: nil)
                    }
                })
            }
        }
    }
    
    //Incoming notifications
    func currentUserShareRequest(currentUser: UserParseHelper!, acceptedByMatch match: UserParseHelper!) {
        /*
        * Fetch ShareRelation, set ShareState, send Notification
        */
        ShareRelationship.fetchShareRelationshipBetween(currentUser, andMatch: match) { (sharerelation, error) -> Void in
            if error == nil {
                self.setCurrentUser(currentUser, shareState: .Sharing, forRelation: sharerelation!, completion: { (success, error) -> Void in
                    if success {
                        //NSNotificationCenter.defaultCenter().postNotificationName(self.kRequestRejectedNotification, object: nil, userInfo: ["article":self])
                        NSNotificationCenter.defaultCenter().postNotificationName(self.kRequestAcceptedNotification, object: nil)
                    }
                })
            }
        }
    }
    
    func currentUserShareRequest(currentUser: UserParseHelper!, rejectedByMatch match: UserParseHelper!) {
        /*
        * Fetch ShareRelation, set ShareState, send Notification
        */
        ShareRelationship.fetchShareRelationshipBetween(currentUser, andMatch: match) { (sharerelation, error) -> Void in
            if error == nil {
                self.setCurrentUser(currentUser, shareState: .Rejected, forRelation: sharerelation!, completion: { (success, error) -> Void in
                    if success {
                        //NSNotificationCenter.defaultCenter().postNotificationName(self.kRequestAcceptedNotification, object: nil, userInfo: ["article":self])
                        NSNotificationCenter.defaultCenter().postNotificationName(self.kRequestRejectedNotification, object: nil)
                    }
                })
            }
        }
    }
}
