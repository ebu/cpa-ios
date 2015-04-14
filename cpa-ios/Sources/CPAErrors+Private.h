//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPAErrors.h"

/**
 * Private interface for implementation purposes
 */

NS_ASSUME_NONNULL_BEGIN

/**
 * Return the error code matching a given identifier
 */
CPAErrorCode CPAErrorCodeForIdentifier(NSString *errorIdentifier);

/**
 * Return the localized description of an error given by its code or identifier
 */
NSString *CPALocalizedErrorDescriptionForCode(CPAErrorCode errorCode);
NSString *CPALocalizedErrorDescriptionForIdentifier(NSString *errorIdentifier);

/**
 * Return a proper error built from its code or identifier
 */
NSError *CPAErrorFromCode(CPAErrorCode errorCode);
NSError *CPAErrorFromIdentifier(NSString *errorIdentifier);

/**
 * Return nicer CFNetwork-related error messages
 */
NSString *CPALocalizedDescriptionForCFNetworkError(NSInteger errorCode);

NS_ASSUME_NONNULL_END
