//
//  BSTwitterFramework+Additions.h
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 11-12-11.
//  Copyright (c) 2011 Basil Salad Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (BSTwitterFramework)


+(NSError*) errorWithTwitterResult:(NSDictionary*) twitterErrors underlyingError:(NSError*) underlying;

+(NSError*) errorWithTwitterResults:(NSArray*) twitterErrors;

@end


extern NSString* const BSTwitterErrorDomain;

extern const int NSTwitterErrorCodeDirectMessagesNotAllowed;
