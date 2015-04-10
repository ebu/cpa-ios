//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (EBUCPAExtensions)

/**
 * Helper method to conveniently get a response as a JSON dictionary, with a completion handler called on the main thread
 */
- (NSURLSessionDataTask *)ebucpa_JSONDictionaryTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSDictionary *responseDictionary, NSURLResponse *response, NSError *error))completionHandler;

@end
