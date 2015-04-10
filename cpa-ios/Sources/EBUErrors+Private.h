//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "EBUErrors.h"

/**
 * Private interface for implementation purposes
 */

/**
 * Return the error code matching a given identifier
 */
EBUAuthenticationErrorCode EBUAuthenticationErrorCodeForIdentifier(NSString *errorIdentifier);

/**
 * Return the localized description of an error given by its code or identifier
 */
NSString *EBULocalizedErrorDescriptionForCode(EBUAuthenticationErrorCode errorCode);
NSString *EBULocalizedErrorDescriptionForIdentifier(NSString *errorIdentifier);

/**
 * Return a proper error built from its code or identifier
 */
NSError *EBUErrorFromCode(EBUAuthenticationErrorCode errorCode);
NSError *EBUErrorFromIdentifier(NSString *errorIdentifier);

/**
 * Return nicer CFNetwork-related error messages
 */
NSString *EBULocalizedDescriptionForCFNetworkError(NSInteger errorCode);
