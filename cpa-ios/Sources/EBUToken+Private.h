//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "EBUToken.h"

@interface EBUToken (Private)

- (instancetype)initWithValue:(NSString *)value domain:(NSString *)domain;

@property (nonatomic, copy) NSString *domainName;
@property (nonatomic, getter=isAuthenticated) BOOL authenticated;

@end
