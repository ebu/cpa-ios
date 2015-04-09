//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <Foundation/Foundation.h>

@interface EBUToken : NSObject

@property (nonatomic, readonly, copy) NSString *value;
@property (nonatomic, readonly, copy) NSString *domain;
@property (nonatomic, readonly, copy) NSString *domainName;
@property (nonatomic, readonly, getter=isAuthenticated) BOOL authenticated;

@end

@interface EBUToken (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end
