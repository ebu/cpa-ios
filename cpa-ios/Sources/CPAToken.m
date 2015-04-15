//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPAToken.h"

@interface CPAToken ()

@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic, copy) NSString *domainName;
@property (nonatomic) CPATokenType type;
@property (nonatomic) NSInteger lifetimeInSeconds;

@end

@implementation CPAToken

#pragma mark Object lifecycle

- (instancetype)initWithValue:(NSString *)value
                       domain:(NSString *)domain
                   domainName:(NSString *)domainName
                         type:(CPATokenType)type
            lifetimeInSeconds:(NSInteger)lifetimeInSeconds
{
    NSParameterAssert(value);
    NSParameterAssert(domain);
    NSParameterAssert(domainName);
    
    if (self = [super init]) {
        self.value = value;
        self.domain = domain;
        self.domainName = domainName;
        self.type = type;
        self.lifetimeInSeconds = lifetimeInSeconds;
    }
    return self;
}

#pragma mark NSCoding protocol

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    CPAToken *token = [CPAToken new];
    token.value = [aDecoder decodeObjectForKey:@"value"];
    token.domain = [aDecoder decodeObjectForKey:@"domain"];
    token.domainName = [aDecoder decodeObjectForKey:@"domainName"];
    token.type = [aDecoder decodeIntegerForKey:@"type"];
    token.lifetimeInSeconds = [aDecoder decodeIntegerForKey:@"lifetimeInSeconds"];
    return token;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.domain forKey:@"domain"];
    [aCoder encodeObject:self.domainName forKey:@"domainName"];
    [aCoder encodeInteger:self.type forKey:@"type"];
    [aCoder encodeInteger:self.lifetimeInSeconds forKey:@"lifetimeInSeconds"];
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; value: %@; domain: %@; domainName: %@; type: %@; lifetimeInSeconds: %@>",
            [self class],
            self,
            self.value,
            self.domain,
            self.domainName,
            (self.type == CPATokenTypeClient) ? @"Client" : @"User",
            @(self.lifetimeInSeconds)];
}

@end
