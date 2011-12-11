//
//  BSTwitterRequest.h
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 11-12-11.
//  Copyright (c) 2011 Basil Salad Software. All rights reserved.
//

#import <Foundation/Foundation.h>

enum BSTwitterRequestMethod {
    BSTwitterRequestMethodGET,
    BSTwitterRequestMethodPOST,
    BSTwitterRequestMethodDELETE
};
typedef enum BSTwitterRequestMethod BSTwitterRequestMethod;

typedef void(^BSTwitterJSONRequestHandler)(id jsonResult, NSError *error);


//----

@interface BSTwitterRequest : NSObject

- (id)initWithURL:(NSURL *)url parameters:(NSDictionary *)parameters requestMethod:(BSTwitterRequestMethod)requestMethod;


@property (nonatomic,readonly,strong) NSURL* URL;

@property (nonatomic,readonly,strong) NSDictionary* parameters;

@property (nonatomic,readonly) BSTwitterRequestMethod requestMethod;

@property (nonatomic,strong) NSString* consumerKey;
@property (nonatomic,strong) NSString* consumerSecret;

@property (nonatomic,strong) NSString* accessToken;
@property (nonatomic,strong) NSString* accessTokenSecret;


-(void) performRequestWithJSONHandler:(BSTwitterJSONRequestHandler) handler;

@end
