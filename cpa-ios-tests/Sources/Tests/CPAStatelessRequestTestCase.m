//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPAStatelessRequest.h"
#import "HTTPStub.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

static NSTimeInterval kConnectionTimeOut = 60;

@interface CPAStatelessRequestTestCase : XCTestCase

@end

@implementation CPAStatelessRequestTestCase

#pragma mark Setup and teardown

- (void)tearDown
{
    [HTTPStub removeAllStubs];
}

#pragma mark Tests

- (void)testRegisterClient
{
    [HTTPStub installStubWithName:@"register_client"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Register client"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest registerClientWithAuthorizationProviderURL:authorizationProviderURL clientName:@"iOS Test" softwareIdentifier:@"ch.ebu.ios_test" softwareVersion:@"0.1" completionBlock:^(NSString *clientIdentifier, NSString *clientSecret, NSError *error) {
        XCTAssertNil(error);
        
        XCTAssertEqualObjects(clientIdentifier, @"407");
        XCTAssertEqualObjects(clientSecret, @"f9f1c336a59219e05a59eecb40eb49eb");
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRequestCode
{
    [HTTPStub installStubWithName:@"request_code"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request code"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest requestCodeWithAuthorizationProviderURL:authorizationProviderURL clientIdentifier:@"407" clientSecret:@"f9f1c336a59219e05a59eecb40eb49eb" domain:@"cpa.rts.ch" completionBlock:^(NSString *deviceCode, NSString *userCode, NSURL *verificationURL, NSInteger pollingIntervalInSeconds, NSInteger expiresInSeconds, NSError *error) {
        XCTAssertNil(error);
        
        XCTAssertEqualObjects(deviceCode, @"3ddd6b1e-d710-4eeb-ada8-a0d48f6cb0d1");
        XCTAssertEqualObjects(userCode, @"KjaCtqSC");
        XCTAssertEqualObjects(verificationURL, [NSURL URLWithString:@"https://cpa.rts.ch"]);
        XCTAssertEqual(pollingIntervalInSeconds, 5);
        XCTAssertEqual(expiresInSeconds, 3599);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRequestClientToken
{
    [HTTPStub installStubWithName:@"request_client_token"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request code"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest requestClientTokenWithAuthorizationProviderURL:authorizationProviderURL clientIdentifier:@"407" clientSecret:@"0b596bf22cf992b8fd8202126ee5db40" domain:@"cpa.rts.ch" completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
        XCTAssertNil(error);
        
        XCTAssertNil(userName);
        XCTAssertEqualObjects(accessToken, @"5ba522aa04f23a9075da61f6d859e347");
        XCTAssertEqualObjects(tokenType, @"bearer");
        XCTAssertEqualObjects(domainName, @"RTS - HbbTV demo");
        XCTAssertEqual(expiresInSeconds, 2591999);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRequestUserTokenAccepted
{
    [HTTPStub installStubWithName:@"request_user_token_accepted"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request code"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest requestUserTokenWithAuthorizationProviderURL:authorizationProviderURL deviceCode:@"3ddd6b1e-d710-4eeb-ada8-a0d48f6cb0d1" clientIdentifier:@"407" clientSecret:@"f9f1c336a59219e05a59eecb40eb49eb" domain:@"cpa.rts.ch" completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
        XCTAssertNil(error);
        
        XCTAssertEqualObjects(userName, @"james@nowhere.com");
        XCTAssertEqualObjects(accessToken, @"614bc2b750852c79fbd8edfa8f9f4561");
        XCTAssertEqualObjects(tokenType, @"bearer");
        XCTAssertEqualObjects(domainName, @"RTS - HbbTV demo");
        XCTAssertEqual(expiresInSeconds, 2591999);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRequestUserTokenPending
{

}

- (void)testRefreshUserToken
{

}

@end
