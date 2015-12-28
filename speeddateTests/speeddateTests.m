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
#import <Parse/PFObject+Subclass.h>

@interface speeddateTests : XCTestCase {
    
    UserParseHelper *testUser;
    UserParseHelper *testMatch;
    RevealRequest *testRequest;
}


@end

@implementation speeddateTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [self getUsers];
    [self fetchRequest];
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

- (void)testFetchRevealRequest
{
    NSString *description = @"Test RevealRequsts between users fetched";
    XCTestExpectation *expection = [self expectationWithDescription:description];
    
    PFQuery *requestFromQuery = [RevealRequest query];
    [requestFromQuery whereKey:@"requestFromUser" equalTo:testUser];
    [requestFromQuery whereKey:@"requestToUser" equalTo:testMatch];
    
    PFQuery *requestToQuery = [RevealRequest query];
    [requestToQuery whereKey:@"requestToUser" equalTo:testUser];
    [requestToQuery whereKey:@"requestFromUser" equalTo:testMatch];
    
    PFQuery *orQuery = [PFQuery orQueryWithSubqueries:@[requestFromQuery, requestToQuery]];
    [orQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (!error) {
            if (objects.count > 0) {
                for (RevealRequest *request in objects) {
                    UserParseHelper *fromRequestUser = (UserParseHelper *)[request.requestFromUser fetchIfNeeded];
                    UserParseHelper *toRequestUser = (UserParseHelper *)[request.requestToUser fetchIfNeeded];
                    
                    if ([fromRequestUser isEqual:testUser]) {
                        
                        [expection fulfill];
                    } else if ([toRequestUser isEqual:testUser]) {
                        
                        [expection fulfill];
                    }
                }
            } else {
                XCTFail(@"There should be Request returned");
            }
        } else {
            // Handle error
        }
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
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
    XCTAssertNotNil(testRequest, @"Test Request should not be nil");
    NSString *description = @"Test User accepted RevealRequest from Test Match";
    XCTestExpectation *expection = [self expectationWithDescription:description];
    
    [testRequest acceptShareRequestWithCompletion:^(BOOL shared) {
        if (shared) {
            XCTAssertTrue(shared == true, @"Shared callback should return True");
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
    NSString *requestId = @"mifSfrXY0R";
    NSString *description = @"Retrieved Test RevealRequest";
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    
    PFQuery *requestQuery = [RevealRequest query];
    [requestQuery getObjectInBackgroundWithId:requestId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (!error) {
            testRequest = (RevealRequest *)object;
        }
        
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

@end
