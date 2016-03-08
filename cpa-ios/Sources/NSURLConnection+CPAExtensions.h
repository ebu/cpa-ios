//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "CPANullability.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Types
typedef void (^CPADictionaryCompletionHandler)(NSDictionary * __nullable responseDictionary, NSURLResponse *response, NSError * __nullable error);

/**
 * Convenience NSURLConnection additions
 */
@interface NSURLConnection (CPAExtensions)

/**
 * Helper method to conveniently get a response as a JSON dictionary, with a completion handler called on the main thread
 */
+ (void)cpa_JSONDictionaryWithRequest:(NSURLRequest *)request completionHandler:(nullable CPADictionaryCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
