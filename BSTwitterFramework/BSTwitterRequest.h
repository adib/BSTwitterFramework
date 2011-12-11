//
//  BSTwitterRequest.h
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 11-12-11.
//  Copyright (c) 2011 Basil Salad Software. Some rights reserved – refer to the included LICENSE file.
//  http://basil-salad.com
//

#import <Foundation/Foundation.h>

/**
 HTTP Request Method for a Twitter request.
 */
enum BSTwitterRequestMethod {
    BSTwitterRequestMethodGET,
    BSTwitterRequestMethodPOST,
    BSTwitterRequestMethodDELETE
};
typedef enum BSTwitterRequestMethod BSTwitterRequestMethod;


/**
 Callback block type for a Twitter request result.
 @param jsonResult the JSON data returned from Twitter, if there isn't any error. Otherwise it is nil.
 @param error any error encountered on the request or parsing JSON data.
 */
typedef void(^BSTwitterJSONRequestHandler)(id jsonResult, NSError *error);


//----

/**
 A BSTwitterRequest object encapsulates HTTP Request you make to Twitter to perform operations on behalf of the user.
 This class is roughly equivalent to TWRequest but can be used to access direct messages (if your application have been authorized
 by the user) and is not dependent on the system's Twitter account.
 
 @author Sasmito Adibowo
 */
@interface BSTwitterRequest : NSObject

/**
 The designated initializer.
 @param url The target Twitter URL.
 @param parameters Request parameters
 @param requestMethod the HTTP Method that will be used.
 */
- (id)initWithURL:(NSURL *)url parameters:(NSDictionary *)parameters requestMethod:(BSTwitterRequestMethod)requestMethod;


/**
 The request's URL.
 */
@property (nonatomic,readonly,strong) NSURL* URL;

/**
 Request parameters.
 */
@property (nonatomic,readonly,strong) NSDictionary* parameters;

/**
 Request method.
 */
@property (nonatomic,readonly) BSTwitterRequestMethod requestMethod;

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


/**
 Executes the HTTP Request asynchronously, parse the JSON data returned and return the JSON result to the handler.
 @param handler The handling block that will act on the JSON data returned. There is no guarantee which thread that this block will be executed in.
 */
-(void) performRequestWithJSONHandler:(BSTwitterJSONRequestHandler) handler;

@end
