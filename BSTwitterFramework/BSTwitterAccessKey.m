//
//  BSTwitterAccessToken.m
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 13-12-11.
//  Copyright (c) 2011 Basil Salad Software. Some rights reserved – refer to the included LICENSE file.
//  http://basil-salad.com
//

#import "BSTwitterAccessKey.h"

@implementation BSTwitterAccessKey

@synthesize consumerKey;
@synthesize consumerSecret;
@synthesize accessToken;
@synthesize accessTokenSecret;


-(id)initWithConsumerKey:(NSString *)key consumerSecret:(NSString *)secret
{
    if (!(self = [super init])) {
        return nil;
    }
    
    consumerKey = key;
    consumerSecret = secret;
    return self;
}

-(id)init
{
    return [self initWithConsumerKey:@"" consumerSecret:@""];
}

-(id)copyWithZone:(NSZone *)zone {
    return [self copy];
}

-(id) copy {
    BSTwitterAccessKey* other = (BSTwitterAccessKey* )[super copy];
    other.consumerKey = consumerKey;
    other.consumerSecret = consumerSecret;
    other.accessToken = accessToken;
    other.accessTokenSecret = accessTokenSecret;
    return other;
}

-(NSString*) description {
    return [NSString stringWithFormat:@"%@ {\n\tconsumerKey:\t%@\n\tconsumerSecret:\t%@\n\taccessToken:\t%@\n\taccessTokenSecret:\t%@\n}",
            [self class],self.consumerKey,self.consumerSecret,self.accessToken,self.accessTokenSecret];
}

@end
