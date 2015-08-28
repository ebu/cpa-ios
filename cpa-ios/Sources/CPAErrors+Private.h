//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPAErrors.h"
#import "CPANullability.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Private interface for implementation purposes
 */

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
 * Return nicer CFNetwork-related error messages (return nil if no match is found)
 */
NSString * __nullable CPALocalizedDescriptionForCFNetworkError(NSInteger errorCode);

NS_ASSUME_NONNULL_END
