//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "NSURLSession+CPAExtensions.h"

#import "CPAErrors+Private.h"

@implementation NSURLSession (CPAExtensions)

- (NSURLSessionDataTask *)cpa_JSONDictionaryTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSDictionary *responseDictionary, NSURLResponse *response, NSError *error))completionHandler
{
    return [self dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
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
            
            id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if (! responseJSON || ! [responseJSON isKindOfClass:[NSDictionary class]]) {
                NSError *parsingError = CPAErrorFromCode(CPAErrorInvalidResponse);
                completionHandler ? completionHandler(nil, response, parsingError) : nil;
                return;
            }
            
            NSDictionary *responseDictionary = responseJSON;

            // Deal with errors which might have been returned in the response JSON
            NSString *errorIdentifier = responseDictionary[@"error"] ?: responseDictionary[@"reason"];
            if (errorIdentifier) {
                NSError *responseError = CPAErrorFromIdentifier(errorIdentifier);
                completionHandler ? completionHandler(nil, response, responseError) : nil;
                return;
            }
            
            completionHandler ? completionHandler(responseDictionary, response, nil) : nil;
        });
    }];
}

@end
