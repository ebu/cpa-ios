//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSURLConnection+CPAExtensions.h"

#import "CPAErrors+Private.h"

@implementation NSURLConnection (CPAExtensions)

+ (void)cpa_JSONDictionaryWithRequest:(NSURLRequest *)request completionHandler:(nullable CPADictionaryCompletionHandler)completionHandler
{
    return [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSString *betterLocalizedDescription = CPALocalizedDescriptionForCFNetworkError(error.code);
            if (! betterLocalizedDescription) {
                completionHandler ? completionHandler(nil, response, error) : nil;
            }
            else {
                NSMutableDictionary *betterUserInfo = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
                betterUserInfo[NSLocalizedDescriptionKey] = betterLocalizedDescription;
                
                NSError *betterError = [NSError errorWithDomain:error.domain code:error.code userInfo:betterUserInfo];
                completionHandler ? completionHandler(nil, response, betterError) : nil;
            }
            return;
        }
        
        id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
        if (! responseJSON || ! [responseJSON isKindOfClass:[NSMutableDictionary class]]) {
            NSError *parsingError = CPAErrorFromCode(CPAErrorInvalidResponse);
            completionHandler ? completionHandler(nil, response, parsingError) : nil;
            return;
        }
        
        NSMutableDictionary *responseDictionary = responseJSON;
        [[responseDictionary copy] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (obj == [NSNull null]) {
                [responseDictionary removeObjectForKey:key];
            }
        }];
        
        // Deal with errors which might have been returned in the response JSON
        NSString *errorIdentifier = responseDictionary[@"error"] ?: responseDictionary[@"reason"];
        if (errorIdentifier) {
            NSError *responseError = CPAErrorFromIdentifier(errorIdentifier);
            completionHandler ? completionHandler(nil, response, responseError) : nil;
            return;
        }
        
        completionHandler ? completionHandler(responseDictionary, response, nil) : nil;
    }];
}

@end
