//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPAStatelessRequest.h"
#import "NSBundle+Tests.h"
#import "OHHTTPStubs.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

static NSTimeInterval kConnectionTimeOut = 60;

@interface CPAStatelessRequestTestCase : XCTestCase

@end

@implementation CPAStatelessRequestTestCase

#pragma mark Setup and teardown

- (void)setUp
{
    // TODO: Setup stubs
#if 0
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        
    }];
#endif
}

- (void)tearDown
{
    [OHHTTPStubs removeAllStubs];
}

#pragma mark Tests

- (void)testExample
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Client registration request"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest registerClientWithAuthorizationProviderURL:authorizationProviderURL clientName:@"a" softwareIdentifier:@"b" softwareVersion:@"c" completionBlock:^(NSString *clientIdentifier, NSString *clientSecret, NSError *error) {
        // ...
        
        [expectation fulfill];
    }];
    
    // TODO: Provide a wrapper which takes a cassette name as parameter and load / release it
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        // ...
    }];
}

@end
