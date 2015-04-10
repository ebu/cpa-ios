//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <Foundation/Foundation.h>

/**
 * Authentication error codes
 */
typedef NS_ENUM(NSInteger, EBUAuthenticationErrorCode) {
    EBUAuthenticationErrorUnknown,                  // An unknown error has occurred
    EBUAuthenticationErrorInvalidRequest,           // The request is invalid
    EBUAuthenticationErrorInvalidResponse,          // The response is invalid
    EBUAuthenticationErrorInvalidClient,            // The client is invalid
    EBUAuthenticationErrorTooFast,                  // Requests are made too fast. Slow down
    EBUAuthenticationErrorPendingAuthorization,     // Authorization has not yet been made
    EBUAuthenticationErrorAuthorizationDenied       // The user denied access to the application
};

/**
 * Common domain of authentication errors
 */
OBJC_EXPORT NSString * const EBUAuthenticationErrorDomain;
