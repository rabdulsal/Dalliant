//
//  speeddate.m
//  speeddateTests
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import <XCTest/XCTest.h>
#import "RevealRequest.h"
#import "UserParseHelper.h"
#import <Parse/Parse.h>

@interface speeddateTests : XCTestCase {
    
    UserParseHelper *testUser;
    UserParseHelper *testMatch;
}


@end

@implementation speeddateTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [self getUsers];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testSendRevealRequest
{
    XCTAssertNotNil(testMatch, @"Test Match should not be nil");
    XCTAssertNotNil(testUser, @"Test User should not be nil");
    NSString *description = @"Test User sent RevealRequst to Test Match";
    XCTestExpectation *expection = [self expectationWithDescription:description];
    
    RevealRequest *request = [RevealRequest object];
    [request sendShareRequestFromUser:testUser toMatch:testMatch completion:^(BOOL success) {
        //
        if (success) {
            // Fetch RevealRequest
            
            [RevealRequest fetchShareRequestWithId:request.objectId completion:^(RevealRequest *incomingRequest, BOOL fetched) {
                if (incomingRequest) {
                    
                    XCTAssertNotNil(incomingRequest.objectId, @"Incoming Request should not be nil");
                }
                
                [expection fulfill];
            }];
            
        }
        
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testAcceptRevealRequest
{
    NSString *description = @"Test User accepted RevealRequest from Test Match";
    XCTestExpectation *expection = [self expectationWithDescription:description];
    
    // Fetch RevealRequest
    [RevealRequest getRequestsBetween:testUser andMatch:testMatch completion:^(RevealRequest *outgoingRequest, RevealRequest *incomingRequest) {
        if (outgoingRequest) {
            
            [outgoingRequest acceptShareRequestWithCompletion:^(BOOL shared) {
                if (shared) {
                    XCTAssertTrue(outgoingRequest.requestReply == [NSNumber numberWithBool:YES], @"Reply to request should be 'YES'");
                }
            }];
            [expection fulfill];
        }
        
        if (incomingRequest) {
            
            [incomingRequest acceptShareRequestWithCompletion:^(BOOL shared) {
                if (shared) {
                    XCTAssertTrue(incomingRequest.requestReply == [NSNumber numberWithBool:YES], @"Reply to request should be 'YES'");
                }
            }];
            [expection fulfill];
        } 
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
    
}

#pragma mark - Helper Methods

- (void)getUsers
{
    NSString *userID = @"ovDKmA2OwE"; //Madison
    NSString *matchID = @"OqGlWzfsYe"; //Rashad
    NSString *description = @"Get Test User and Test Match";
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    
    PFQuery *userQuery = [UserParseHelper query];
    PFQuery *matchQuery = [UserParseHelper query];
    [userQuery getObjectInBackgroundWithId:userID block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (!error) {
            testUser = (UserParseHelper *)object;
        
            [matchQuery getObjectInBackgroundWithId:matchID block:^(PFObject * _Nullable object, NSError * _Nullable error) {
                if (!error) {
                    testMatch = (UserParseHelper *)object;
                    
                    [expectation fulfill];
                }
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)verifyExistingMatches
{
    
}

- (void)fetchRequest
{
    [RevealRequest getRequestsBetween:testUser andMatch:testMatch completion:^(RevealRequest *outgoingRequest, RevealRequest *incomingRequest) {
        //
    }];
}

@end
