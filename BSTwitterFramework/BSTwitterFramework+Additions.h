//
//  BSTwitterFramework+Additions.h
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 11-12-11.
//  Copyright (c) 2011 Basil Salad Software. Some rights reserved – refer to the included LICENSE file.
//  http://basil-salad.com
//

#import <Foundation/Foundation.h>

@interface NSError (BSTwitterFramework)


/**
 Creates an Error object from a number of twitter errors returned in a JSON data.
 The error object will contain data from the first element in the array and subsequent errors will be stored
 inside this error object's userInfo keyed in NSUnderlyingErrorKey, recursively. That each subsequent errors
 are stored as the former error's underlying error.
 
 @param twitterErrors An array of dictionary objects that contains parsed JSON error data obtained from Twitter.
 */
+(NSError*) errorWithTwitterResults:(NSArray*) twitterErrors;

/**
 Creates an error object from a JSON Dictionary of errors
 @param twitterError a parsed JSON dictionary containing the error.
 @param underlying the underlying error that caused this error, nil if there isn't any.
 */
+(NSError*) errorWithTwitterResult:(NSDictionary*) twitterError underlyingError:(NSError*) underlying;


@end


/**
 The error domain of errors returned by Twitter.
 */
extern NSString* const BSTwitterErrorDomain;

/**
 The Twitter error
 */
enum BSTwitterErrorCode {
    BSTwitterErrorCodeNone = 0,
    BSTwitterErrorCodeDirectMessagesNotAllowed = 93
};
