//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPAErrors.h"

#import "NSBundle+CPAExtensions.h"

// Constants
NSString * const CPAErrorDomain = @"ch.ebu.cpa.error";

CPAErrorCode CPAErrorCodeForIdentifier(NSString *errorIdentifier)
{
    NSCParameterAssert(errorIdentifier);
    
    static NSDictionary *s_errorCodes;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_errorCodes = @{ @"invalid_request" : @(CPAErrorInvalidRequest),
                          @"invalid_client" : @(CPAErrorInvalidClient),
                          @"slow_down" : @(CPAErrorTooFast),
                          @"authorization_pending" : @(CPAErrorPendingAuthorization),
                          @"cancelled" : @(CPAErrorAuthorizationDenied),
                          @"user_code:denied" : @(CPAErrorAuthorizationDenied),
                          @"expired" : @(CPAErrorAuthorizationRequestExpired) };
    });
    
    NSNumber *errorCode = s_errorCodes[errorIdentifier];
    return errorCode ? [errorCode integerValue] : CPAErrorUnknown;
}

NSString *CPALocalizedErrorDescriptionForCode(CPAErrorCode errorCode)
{
    static NSDictionary *s_localizedErrorDescriptions;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_localizedErrorDescriptions = @{ @(CPAErrorUnknown) : CPALocalizedString(@"An unknown error has been encountered", nil),
                                          @(CPAErrorInvalidRequest) : CPALocalizedString(@"The request is invalid", nil),
                                          @(CPAErrorInvalidResponse) : CPALocalizedString(@"The response is invalid", nil),
                                          @(CPAErrorInvalidClient) : CPALocalizedString(@"The client is invalid", nil),
                                          @(CPAErrorTooFast) : CPALocalizedString(@"Too many requests are being made", nil),
                                          @(CPAErrorPendingAuthorization) : CPALocalizedString(@"Authorization is still pending", nil),
                                          @(CPAErrorAuthorizationCancelled) : CPALocalizedString(@"The authorization request has been cancelled", nil),
                                          @(CPAErrorAuthorizationDenied) : CPALocalizedString(@"Authorization was denied", nil),
                                          @(CPAErrorAuthorizationRequestExpired) : CPALocalizedString(@"The authorization request has expired", nil) };
    });
    return s_localizedErrorDescriptions[@(errorCode)];
}

NSString *CPALocalizedErrorDescriptionForIdentifier(NSString *errorIdentifier)
{
    NSCParameterAssert(errorIdentifier);
    
    CPAErrorCode errorCode = CPAErrorCodeForIdentifier(errorIdentifier);
    return CPALocalizedErrorDescriptionForCode(errorCode);
}

NSError *CPAErrorFromCode(CPAErrorCode errorCode)
{
    return [NSError errorWithDomain:CPAErrorDomain
                               code:errorCode
                           userInfo:@{ NSLocalizedDescriptionKey : CPALocalizedErrorDescriptionForCode(errorCode) } ];
}

NSError *CPAErrorFromIdentifier(NSString *errorIdentifier)
{
    NSCParameterAssert(errorIdentifier);
    
    return [NSError errorWithDomain:CPAErrorDomain
                               code:CPAErrorCodeForIdentifier(errorIdentifier)
                           userInfo:@{ NSLocalizedDescriptionKey : CPALocalizedErrorDescriptionForIdentifier(errorIdentifier) } ];
}

NSString *CPALocalizedDescriptionForCFNetworkError(NSInteger errorCode)
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.apple.CFNetwork"];
    NSString *key = [NSString stringWithFormat:@"Err%@", @(errorCode)];
    return [bundle localizedStringForKey:key value:nil table:nil];
}
