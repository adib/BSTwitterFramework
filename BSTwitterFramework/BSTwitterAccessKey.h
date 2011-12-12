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
@interface BSTwitterAccessKey : NSObject<NSCopying>

/**
 The Twitter application's Consumer Key string. Initialize this before performing the request.
 */
@property (nonatomic,strong) NSString* consumerKey;

/**
 The Twitter application's Consumer Secret string. Initialize this before performing the request.
 */
@property (nonatomic,strong) NSString* consumerSecret;

/**
 The Twitter application's Access Token string. Initialize this before performing the request.
 @see BSWebAuthViewController
 */
@property (nonatomic,strong) NSString* accessToken;

/**
 The Twitter application's Access Token Secret string. Initialize this before performing the request.
 @see BSWebAuthViewController
 */
@property (nonatomic,strong) NSString* accessTokenSecret;

@end
