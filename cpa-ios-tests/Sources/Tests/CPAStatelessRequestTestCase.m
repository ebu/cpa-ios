//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "CPAErrors.h"
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

- (void)testRegisterClientNetworkError
{
    [HTTPStub installStubWithName:HTTPStubNetworkConnectionLost];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Register client (network error)"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest registerClientWithAuthorizationProviderURL:authorizationProviderURL clientName:@"iOS Test" softwareIdentifier:@"ch.ebu.ios_test" softwareVersion:@"0.1" completionBlock:^(NSString *clientIdentifier, NSString *clientSecret, NSError *error) {
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain);
        XCTAssertEqual(error.code, NSURLErrorNetworkConnectionLost);
        
        XCTAssertNil(clientIdentifier);
        XCTAssertNil(clientSecret);
        
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

- (void)testRequestCodeInvalidClient
{
    [HTTPStub installStubWithName:@"request_code_invalid_client"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request code (invalid client)"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest requestCodeWithAuthorizationProviderURL:authorizationProviderURL clientIdentifier:@"1NV4L1DCL13N7" clientSecret:@"1NV4L1D53CR37" domain:@"cpa.rts.ch" completionBlock:^(NSString *deviceCode, NSString *userCode, NSURL *verificationURL, NSInteger pollingIntervalInSeconds, NSInteger expiresInSeconds, NSError *error) {
        XCTAssertEqualObjects(error.domain, CPAErrorDomain);
        XCTAssertEqual(error.code, CPAErrorInvalidClient);
        
        XCTAssertNil(deviceCode);
        XCTAssertNil(userCode);
        XCTAssertNil(verificationURL);
        XCTAssertEqual(pollingIntervalInSeconds, 0);
        XCTAssertEqual(expiresInSeconds, 0);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRequestCodeNetworkError
{
    [HTTPStub installStubWithName:HTTPStubNetworkConnectionLost];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request code (network error)"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest requestCodeWithAuthorizationProviderURL:authorizationProviderURL clientIdentifier:@"407" clientSecret:@"f9f1c336a59219e05a59eecb40eb49eb" domain:@"cpa.rts.ch" completionBlock:^(NSString *deviceCode, NSString *userCode, NSURL *verificationURL, NSInteger pollingIntervalInSeconds, NSInteger expiresInSeconds, NSError *error) {
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain);
        XCTAssertEqual(error.code, NSURLErrorNetworkConnectionLost);
        
        XCTAssertNil(deviceCode);
        XCTAssertNil(userCode);
        XCTAssertNil(verificationURL);
        XCTAssertEqual(pollingIntervalInSeconds, 0);
        XCTAssertEqual(expiresInSeconds, 0);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRequestClientToken
{
    [HTTPStub installStubWithName:@"request_client_token"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request client token"];
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

- (void)testRequestClientTokenInvalidClient
{
    [HTTPStub installStubWithName:@"request_client_token_invalid_client"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request client token (invalid client)"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest requestClientTokenWithAuthorizationProviderURL:authorizationProviderURL clientIdentifier:@"1NV4L1DCL13N7" clientSecret:@"1NV4L1D53CR37" domain:@"cpa.rts.ch" completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
        XCTAssertEqualObjects(error.domain, CPAErrorDomain);
        XCTAssertEqual(error.code, CPAErrorInvalidClient);
        
        XCTAssertNil(userName);
        XCTAssertNil(accessToken);
        XCTAssertNil(tokenType);
        XCTAssertNil(domainName);
        XCTAssertEqual(expiresInSeconds, 0);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRequestClientTokenNetworkError
{
    [HTTPStub installStubWithName:HTTPStubNetworkConnectionLost];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request client token (network error)"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest requestClientTokenWithAuthorizationProviderURL:authorizationProviderURL clientIdentifier:@"407" clientSecret:@"0b596bf22cf992b8fd8202126ee5db40" domain:@"cpa.rts.ch" completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain);
        XCTAssertEqual(error.code, NSURLErrorNetworkConnectionLost);
        
        XCTAssertNil(userName);
        XCTAssertNil(accessToken);
        XCTAssertNil(tokenType);
        XCTAssertNil(domainName);
        XCTAssertEqual(expiresInSeconds, 0);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRequestUserToken
{
    [HTTPStub installStubWithName:@"request_user_token"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request user token"];
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

- (void)testRequestUserTokenAuthorizationPending
{
    [HTTPStub installStubWithName:@"request_user_token_authorization_pending"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request user token (pending authorization)"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest requestUserTokenWithAuthorizationProviderURL:authorizationProviderURL deviceCode:@"3ddd6b1e-d710-4eeb-ada8-a0d48f6cb0d1" clientIdentifier:@"407" clientSecret:@"f9f1c336a59219e05a59eecb40eb49eb" domain:@"cpa.rts.ch" completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
        XCTAssertEqualObjects(error.domain, CPAErrorDomain);
        XCTAssertEqual(error.code, CPAErrorPendingAuthorization);
        
        XCTAssertNil(userName);
        XCTAssertNil(accessToken);
        XCTAssertNil(tokenType);
        XCTAssertNil(domainName);
        XCTAssertEqual(expiresInSeconds, 0);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRequestUserTokenDenied
{
    [HTTPStub installStubWithName:@"request_user_token_denied"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request user token (denied)"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest requestUserTokenWithAuthorizationProviderURL:authorizationProviderURL deviceCode:@"3ddd6b1e-d710-4eeb-ada8-a0d48f6cb0d1" clientIdentifier:@"407" clientSecret:@"f9f1c336a59219e05a59eecb40eb49eb" domain:@"cpa.rts.ch" completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
        XCTAssertEqualObjects(error.domain, CPAErrorDomain);
        XCTAssertEqual(error.code, CPAErrorAuthorizationDenied);
        
        XCTAssertNil(userName);
        XCTAssertNil(accessToken);
        XCTAssertNil(tokenType);
        XCTAssertNil(domainName);
        XCTAssertEqual(expiresInSeconds, 0);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRequestUserTokenExpired
{
    [HTTPStub installStubWithName:@"request_user_token_expired"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request user token (expired)"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest requestUserTokenWithAuthorizationProviderURL:authorizationProviderURL deviceCode:@"3ddd6b1e-d710-4eeb-ada8-a0d48f6cb0d1" clientIdentifier:@"407" clientSecret:@"f9f1c336a59219e05a59eecb40eb49eb" domain:@"cpa.rts.ch" completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
        XCTAssertEqualObjects(error.domain, CPAErrorDomain);
        XCTAssertEqual(error.code, CPAErrorAuthorizationRequestExpired);
        
        XCTAssertNil(userName);
        XCTAssertNil(accessToken);
        XCTAssertNil(tokenType);
        XCTAssertNil(domainName);
        XCTAssertEqual(expiresInSeconds, 0);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRequestUserTokenInvalidClient
{
    [HTTPStub installStubWithName:@"request_user_token_invalid_client"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request user token (invalid client)"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest requestUserTokenWithAuthorizationProviderURL:authorizationProviderURL deviceCode:@"1NV4L1DCOD3" clientIdentifier:@"1NV4L1DCL13N7" clientSecret:@"1NV4L1D53CR37" domain:@"cpa.rts.ch" completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
        XCTAssertEqualObjects(error.domain, CPAErrorDomain);
        XCTAssertEqual(error.code, CPAErrorInvalidClient);
        
        XCTAssertNil(userName);
        XCTAssertNil(accessToken);
        XCTAssertNil(tokenType);
        XCTAssertNil(domainName);
        XCTAssertEqual(expiresInSeconds, 0);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRequestUserTokenNetworkError
{
    [HTTPStub installStubWithName:HTTPStubNetworkConnectionLost];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request user token"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest requestUserTokenWithAuthorizationProviderURL:authorizationProviderURL deviceCode:@"3ddd6b1e-d710-4eeb-ada8-a0d48f6cb0d1" clientIdentifier:@"407" clientSecret:@"f9f1c336a59219e05a59eecb40eb49eb" domain:@"cpa.rts.ch" completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain);
        XCTAssertEqual(error.code, NSURLErrorNetworkConnectionLost);
        
        XCTAssertNil(userName);
        XCTAssertNil(accessToken);
        XCTAssertNil(tokenType);
        XCTAssertNil(domainName);
        XCTAssertEqual(expiresInSeconds, 0);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRequestUserTokenSlowDown
{
    [HTTPStub installStubWithName:@"request_user_token_slow_down"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request user token"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest requestUserTokenWithAuthorizationProviderURL:authorizationProviderURL deviceCode:@"3ddd6b1e-d710-4eeb-ada8-a0d48f6cb0d1" clientIdentifier:@"407" clientSecret:@"f9f1c336a59219e05a59eecb40eb49eb" domain:@"cpa.rts.ch" completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
        XCTAssertEqualObjects(error.domain, CPAErrorDomain);
        XCTAssertEqual(error.code, CPAErrorTooFast);
        
        XCTAssertNil(userName);
        XCTAssertNil(accessToken);
        XCTAssertNil(tokenType);
        XCTAssertNil(domainName);
        XCTAssertEqual(expiresInSeconds, 0);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRefreshTokenClient
{
    [HTTPStub installStubWithName:@"refresh_token_client"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Refresh token (client)"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest refreshTokenWithAuthorizationProviderURL:authorizationProviderURL clientIdentifier:@"407" clientSecret:@"0b596bf22cf992b8fd8202126ee5db40" domain:@"cpa.rts.ch" completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
        XCTAssertNil(error);
        
        XCTAssertNil(userName);
        XCTAssertEqualObjects(accessToken, @"2232af6d5daa04f073561a859e95ba77");
        XCTAssertEqualObjects(tokenType, @"bearer");
        XCTAssertEqualObjects(domainName, @"RTS - HbbTV demo");
        XCTAssertEqual(expiresInSeconds, 2591999);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRefreshTokenInvalidClient
{
    [HTTPStub installStubWithName:@"refresh_token_invalid_client"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Refresh client token (invalid client)"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest refreshTokenWithAuthorizationProviderURL:authorizationProviderURL clientIdentifier:@"1NV4L1DCL13N7" clientSecret:@"1NV4L1D53CR37" domain:@"cpa.rts.ch" completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
        XCTAssertEqualObjects(error.domain, CPAErrorDomain);
        XCTAssertEqual(error.code, CPAErrorInvalidClient);
        
        XCTAssertNil(userName);
        XCTAssertNil(accessToken);
        XCTAssertNil(tokenType);
        XCTAssertNil(domainName);
        XCTAssertEqual(expiresInSeconds, 0);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRefreshClientTokenNetworkError
{
    [HTTPStub installStubWithName:HTTPStubNetworkConnectionLost];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Refresh client token (network error)"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest refreshTokenWithAuthorizationProviderURL:authorizationProviderURL clientIdentifier:@"407" clientSecret:@"f9f1c336a59219e05a59eecb40eb49eb" domain:@"cpa.rts.ch" completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain);
        XCTAssertEqual(error.code, NSURLErrorNetworkConnectionLost);
        
        XCTAssertNil(userName);
        XCTAssertNil(accessToken);
        XCTAssertNil(tokenType);
        XCTAssertNil(domainName);
        XCTAssertEqual(expiresInSeconds, 0);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRefreshTokenUser
{
    [HTTPStub installStubWithName:@"refresh_token_user"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Refresh token (user)"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest refreshTokenWithAuthorizationProviderURL:authorizationProviderURL clientIdentifier:@"407" clientSecret:@"f9f1c336a59219e05a59eecb40eb49eb" domain:@"cpa.rts.ch" completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
        XCTAssertNil(error);
        
        XCTAssertEqualObjects(userName, @"james@nowhere.com");
        XCTAssertEqualObjects(accessToken, @"238e39ed96eef7ec2e46f92ba4bcb1b0");
        XCTAssertEqualObjects(tokenType, @"bearer");
        XCTAssertEqualObjects(domainName, @"RTS - HbbTV demo");
        XCTAssertEqual(expiresInSeconds, 2591999);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRefreshTokenJSONWithNull
{
    [HTTPStub installStubWithName:@"refresh_token_json_with_null"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Refresh token (JSON With Null)"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest refreshTokenWithAuthorizationProviderURL:authorizationProviderURL clientIdentifier:@"407" clientSecret:@"f9f1c336a59219e05a59eecb40eb49eb" domain:@"cpa.rts.ch" completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
        XCTAssertNil(error);
        
        XCTAssertNil(userName);
        XCTAssertNil(accessToken);
        XCTAssertNil(tokenType);
        XCTAssertNil(domainName);
        XCTAssertEqual(expiresInSeconds, 0);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

@end
