//
//  ShareRelationship.swift
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 12/20/15.
//  Copyright © 2015 Studio76. All rights reserved.
//

import Foundation

class ShareRelationship : PFObject, PFSubclassing, IdentityRevealDelegate {
    
    enum ShareState: Int {
        case NotSharing = 1, Requested, Sharing, Rejected
    }
    
    @NSManaged var firstRequestedSharer: UserParseHelper
    @NSManaged var secondRequestedSharer: UserParseHelper
    @NSManaged var firstSharerShareState: Int
    @NSManaged var secondSharerShareState: Int

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
    
    func fetchShareRelationshipBetween(currentUser: UserParseHelper, andMatch match: UserParseHelper) {
        var query = ShareRelationship.query()
        query?.whereKey("firstRequestedSharer", equalTo: currentUser)
    }
    
    //MARK: Protocol Methods
    func shareRequestSentFromUser(currentUser: UserParseHelper!, toMatch match: UserParseHelper!) {
        print("ShareRelationship protocol run!")
        //Fetch ShareRelationship from Parse based on first/secondRequestSharer
        //Set first/secondSharerState
        //Set off Notification to update MessagesVC and ChatMessageVC UI
    }
    
    func shareRequestFromUser(currentUser: UserParseHelper!, acceptedByMatch match: UserParseHelper!) {
        //Fetch ShareRelationship from Parse based on first/secondRequestSharer
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
