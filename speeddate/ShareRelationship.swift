//
//  ShareRelationship.swift
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 12/20/15.
//  Copyright © 2015 Studio76. All rights reserved.
//

import Foundation

class ShareRelationship : PFObject, PFSubclassing, IdentityRevealDelegate {
    
    @objc enum ShareState: Int {
        case NotSharing, Requested, Sharing, Rejected
    }
    
    @NSManaged var firstRequestedSharer: String
    @NSManaged var secondRequestedSharer: String
    @NSManaged var firstSharerShareState: Int
    @NSManaged var secondSharerShareState: Int
    var userShareRelation: ShareRelationship?
    
    let fSharer = "firstRequestedSharer", sSharer = "secondRequestedSharer"

    // Notificications
    let kRequestSentNotification     = "requestSentNotification"
    let kRequestAcceptedNotification = "requestAcceptedNotification"
    let kRequestRejectedNotification = "requestRejectedNotification"

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
    
    func fetchShareRelationshipBetween(currentUser: UserParseHelper, andMatch match: UserParseHelper, completion:((sharerelation: ShareRelationship, error: NSError?) -> Void)? = nil) {
        if let query1 = ShareRelationship.query(), query2 = ShareRelationship.query() {
            query1.whereKey(fSharer, equalTo: currentUser.nickname)
            query1.whereKey(sSharer, equalTo: match.nickname)
            query2.whereKey(fSharer, equalTo: match.nickname)
            query2.whereKey(sSharer, equalTo: currentUser.nickname)
            
            let orQuery = PFQuery.orQueryWithSubqueries([query1,query2])
            orQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if (error == nil) {
                    let relation = objects?.first as! ShareRelationship
                    if let completion = completion {
                        completion(sharerelation: relation,error: nil)
                    }
                    
                } else {
                    // No relationships
                }   
            })
        }
    }
    
    func currentUserIsFirstSharer(currentUser: UserParseHelper) -> Bool {
        return currentUser.nickname == userShareRelation!.firstRequestedSharer
    }
    
    func setCurrentUser(currentUser: UserParseHelper, shareState: ShareState, completion:((success: Bool, error: NSError?) -> Void)) {
        if self.currentUserIsFirstSharer(currentUser) {
            userShareRelation?.firstSharerShareState = shareState.rawValue
        } else {
            userShareRelation?.secondSharerShareState = shareState.rawValue
        }
        
        userShareRelation?.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
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
        self.fetchShareRelationshipBetween(currentUser, andMatch: match) { (sharerelation, error) -> Void in
            if error == nil {
                self.userShareRelation = sharerelation
                self.setCurrentUser(currentUser, shareState: .Requested, completion: { (success, error) -> Void in
                    if success {
                        NSNotificationCenter.defaultCenter().postNotificationName(self.kRequestSentNotification, object: nil, userInfo:["article":self])
                    } else {
                        // Handle error
                    }
                })
            }
        }
        //Set first/secondSharerState
        // if cUser is 1stSh : relation.1stSh -> RQT
        
    }
    
    func shareRequestFromUser(currentUser: UserParseHelper!, acceptedByMatch match: UserParseHelper!) {
        //Fetch ShareRelationship from Parse based on first/secondRequestSharer - currentUser
        //Set first/secondSharerState
        //Set off Notification to update MessagesVC and ChatMessageVC UI
    }
    
    func shareRequestFromMatch(match: UserParseHelper!, acceptedByUser currentUser: UserParseHelper!) {
        //Fetch ShareRelationship from Parse based on first/secondRequestSharer
        //Set first/secondSharerState
        //Set off Notification to update MessagesVC and ChatMessageVC UI
    }
    
    func shareRequestFromMatch(match: UserParseHelper!, rejectedByUser currentUser: UserParseHelper!) {
        //Fetch ShareRelationship from Parse based on first/secondRequestSharer
        //Set first/secondSharerState
        //Set off Notification to update MessagesVC and ChatMessageVC UI
    }
}
