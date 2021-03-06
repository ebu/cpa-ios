//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Authentication error codes
 */
typedef NS_ENUM(NSInteger, CPAErrorCode) {
    CPAErrorUnknown,                                // An unknown error has occurred
    CPAErrorInvalidRequest,                         // The request is invalid
    CPAErrorInvalidResponse,                        // The response is invalid
    CPAErrorInvalidClient,                          // The client is invalid
    CPAErrorTooFast,                                // Requests are made too fast. Slow down
    CPAErrorPendingAuthorization,                   // Authorization has not yet been made
    CPAErrorAuthorizationCancelled,                 // The authorization request has been cancelled
    CPAErrorAuthorizationDenied,                    // The user denied access to the application
    CPAErrorAuthorizationRequestExpired             // The authorization request expired
};

/**
 * Common domain of cross-platform authentication errors
 */
OBJC_EXPORT NSString * const CPAErrorDomain;

NS_ASSUME_NONNULL_END
