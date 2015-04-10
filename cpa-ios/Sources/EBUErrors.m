//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "EBUErrors.h"

// Constants
NSString * const EBUAuthenticationErrorDomain = @"ch.ebu.cpa.error";

EBUAuthenticationErrorCode EBUAuthenticationErrorCodeForIdentifier(NSString *errorIdentifier)
{
    static NSDictionary *s_errorCodes;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_errorCodes = @{ @"invalid_request" : @(EBUAuthenticationErrorInvalidRequest),
                          @"invalid_client" : @(EBUAuthenticationErrorInvalidClient),
                          @"slow_down" : @(EBUAuthenticationErrorTooFast),
                          @"authorization_pending" : @(EBUAuthenticationErrorPendingAuthorization),
                          @"user_code:denied" : @(EBUAuthenticationErrorAuthorizationDenied) };
    });
    
    NSNumber *errorCode = s_errorCodes[errorIdentifier];
    return errorCode ? [errorCode integerValue] : EBUAuthenticationErrorUnknown;
}

NSString *EBULocalizedErrorDescriptionForCode(EBUAuthenticationErrorCode errorCode)
{
    static NSDictionary *s_localizedErrorDescriptions;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_localizedErrorDescriptions = @{ @(EBUAuthenticationErrorUnknown) : NSLocalizedString(@"An unknown error has been encountered", nil),
                                          @(EBUAuthenticationErrorInvalidRequest) : NSLocalizedString(@"The request is invalid", nil),
                                          @(EBUAuthenticationErrorInvalidResponse) : NSLocalizedString(@"The response is invalid", nil),
                                          @(EBUAuthenticationErrorInvalidClient) : NSLocalizedString(@"The client is invalid", nil),
                                          @(EBUAuthenticationErrorTooFast) : NSLocalizedString(@"Too many requests are being made", nil),
                                          @(EBUAuthenticationErrorPendingAuthorization) : NSLocalizedString(@"Authorization is still pending", nil),
                                          @(EBUAuthenticationErrorAuthorizationDenied) : NSLocalizedString(@"Authorization was denied", nil)};
    });
    return s_localizedErrorDescriptions[@(errorCode)];
}

NSString *EBULocalizedErrorDescriptionForIdentifier(NSString *errorIdentifier)
{
    EBUAuthenticationErrorCode errorCode = EBUAuthenticationErrorCodeForIdentifier(errorIdentifier);
    return EBULocalizedErrorDescriptionForCode(errorCode);
}

NSError *EBUErrorFromCode(EBUAuthenticationErrorCode errorCode)
{
    return [NSError errorWithDomain:EBUAuthenticationErrorDomain
                               code:errorCode
                           userInfo:@{ NSLocalizedDescriptionKey : EBULocalizedErrorDescriptionForCode(errorCode) } ];
}

NSError *EBUErrorFromIdentifier(NSString *errorIdentifier)
{
    NSCParameterAssert(errorIdentifier);
    
    return [NSError errorWithDomain:EBUAuthenticationErrorDomain
                               code:EBUAuthenticationErrorCodeForIdentifier(errorIdentifier)
                           userInfo:@{ NSLocalizedDescriptionKey : EBULocalizedErrorDescriptionForIdentifier(errorIdentifier) } ];
}

NSString *EBULocalizedDescriptionForCFNetworkError(NSInteger errorCode)
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.apple.CFNetwork"];
    NSString *key = [NSString stringWithFormat:@"Err%@", @(errorCode)];
    return [bundle localizedStringForKey:key value:nil table:nil];
}
