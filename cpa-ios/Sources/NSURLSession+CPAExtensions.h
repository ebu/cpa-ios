//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPANullability.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Types
typedef void (^CPAURLSessionDictionaryResponseBlock)(NSDictionary * __nullable responseDictionary, NSURLResponse *response, NSError * __nullable error);

/**
 * Convenience NSURLSession additions
 */
// TODO: Ugly hack to solve issues with categories on NSURLSession in static libs prior to iOS 8. Remove when minimum required
//       version is iOS 8
//       See http://stackoverflow.com/questions/21629682/ios-nsurlsession-category-methods-not-being-found-at-runtime
@interface NSObject /*NSURLSession*/ (CPAExtensions)

/**
 * Helper method to conveniently get a response as a JSON dictionary, with a completion handler called on the main thread
 */
- (NSURLSessionDataTask *)cpa_JSONDictionaryTaskWithRequest:(NSURLRequest *)request completionHandler:(nullable CPAURLSessionDictionaryResponseBlock)completionHandler;

@end

NS_ASSUME_NONNULL_END
