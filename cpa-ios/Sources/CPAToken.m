//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "CPAToken.h"

@interface CPAToken ()

@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic, copy) NSString *domainName;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic) NSDate *expirationDate;

@end

@implementation CPAToken

#pragma mark Object lifecycle

- (instancetype)initWithValue:(NSString *)value
                       domain:(NSString *)domain
                   domainName:(NSString *)domainName
                     userName:(NSString *)userName
               expirationDate:(NSDate *)expirationDate
{
    NSParameterAssert(value);
    NSParameterAssert(domain);
    NSParameterAssert(domainName);
    NSParameterAssert(expirationDate);
    
    if (self = [super init]) {
        self.value = value;
        self.domain = domain;
        self.domainName = domainName;
        self.userName = userName;
        self.expirationDate = expirationDate;
    }
    return self;
}

#pragma mark Accessors and mutators

- (CPATokenType)type
{
    return (self.userName != nil) ? CPATokenTypeUser : CPATokenTypeClient;
}

#pragma mark NSCoding protocol

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    CPAToken *token = [CPAToken new];
    token.value = [aDecoder decodeObjectForKey:@"value"];
    token.domain = [aDecoder decodeObjectForKey:@"domain"];
    token.domainName = [aDecoder decodeObjectForKey:@"domainName"];
    token.userName = [aDecoder decodeObjectForKey:@"userName"];
    token.expirationDate = [aDecoder decodeObjectForKey:@"expirationDate"];
    return token;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.domain forKey:@"domain"];
    [aCoder encodeObject:self.domainName forKey:@"domainName"];
    [aCoder encodeObject:self.userName forKey:@"userName"];
    [aCoder encodeObject:self.expirationDate forKey:@"expirationDate"];
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; value: %@; domain: %@; domainName: %@; userName: %@; type: %@; expirationDate: %@>",
            [self class],
            self,
            self.value,
            self.domain,
            self.domainName,
            self.userName,
            (self.type == CPATokenTypeClient) ? @"Client" : @"User",
            self.expirationDate];
}

@end
