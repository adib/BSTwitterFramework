//
//  BSTwitterAccessToken.h
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 13-12-11.
//  Copyright (c) 2011 Basil Salad Software. Some rights reserved – refer to the included LICENSE file.
//  http://basil-salad.com

//

#import <Foundation/Foundation.h>

/**
 Encapsulate Twitter's OAuth keys and tokens.
 @author Sasmito Adibowo
 */
@interface BSTwitterAccessKey : NSObject<NSCopying,NSCoding>

/**
 The Twitter application's Consumer Key string. Initialize this before performing the request.
 */
@property (strong) NSString* consumerKey;

/**
 The Twitter application's Consumer Secret string. Initialize this before performing the request.
 */
@property (strong) NSString* consumerSecret;

/**
 The Twitter application's Access Token string. Initialize this before performing the request.
 @see BSWebAuthViewController
 */
@property (strong) NSString* accessToken;

/**
 The Twitter application's Access Token Secret string. Initialize this before performing the request.
 @see BSWebAuthViewController
 */
@property (strong) NSString* accessTokenSecret;

/**
 Designated initializer.
 @param key The Twitter application's Consumer Key string.
 @param secret The Twitter application's Consumer Secret string.
 */
-(id) initWithConsumerKey:(NSString*) key consumerSecret:(NSString*) secret;

/**
 Convenience initializer. Sets the consumer key and consumer secret to blank strings (instead of nil to prevent crashing).
 */
-(id) init;


@end
