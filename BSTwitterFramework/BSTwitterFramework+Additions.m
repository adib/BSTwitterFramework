//
//  BSTwitterFramework+Additions.m
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 11-12-11.
//  Copyright (c) 2011 Basil Salad Software. All rights reserved.
//

#import "BSTwitterFramework+Additions.h"

NSString* const BSTwitterErrorDomain = @"com.basilsalad.BSTwitterErrorDomain";

const int NSTwitterErrorCodeDirectMessagesNotAllowed = 93;

@implementation NSError (BSTwitterFramework)

+(NSError*) errorWithTwitterResult:(NSDictionary*) twitterError underlyingError:(NSError*) underlying {
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    
    if (underlying) {
        [userInfo setObject:underlying forKey:NSUnderlyingErrorKey];
    }
    id message = [twitterError objectForKey:@"message"];
    if (message) {
        [userInfo setObject:message forKey:NSLocalizedDescriptionKey];
    }
    int errorCode = [[twitterError objectForKey:@"code"] intValue];
    
    NSError* error = [NSError errorWithDomain:BSTwitterErrorDomain code:errorCode userInfo:userInfo];
    return error;
    
}

+(NSError*) errorWithTwitterResults:(NSArray*) twitterErrors {
    NSError* lastError = nil;
    NSEnumerator* reverseEnumerator = [twitterErrors reverseObjectEnumerator];
    for (NSDictionary* dict in reverseEnumerator) {
        lastError = [self errorWithTwitterResult:dict underlyingError:lastError];
    }
    return lastError;
}

@end
