//
//  BSTwitterRequest.m
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 11-12-11.
//  Copyright (c) 2011 Basil Salad Software. Some rights reserved – refer to the included LICENSE file.
//  http://basil-salad.com
//

#import "BSTwitterRequest.h"
#import "ASIFormDataRequest.h"
#import "OAuthCore.h"
#import "OAuth+Additions.h"
#import "BSTwitterFramework+Additions.h"
#import "BSTwitterAccessKey.h"

// this is ARC code.
#if !__has_feature(objc_arc)
#error Need automatic reference counting to compile this.
#endif


static NSInteger BSTwitterRequestSortParameter(NSString *key1, NSString *key2, void *context) {
	NSComparisonResult r = [key1 compare:key2];
	if(r == NSOrderedSame) { // compare by value in this case
		NSDictionary *dict = (__bridge NSDictionary *)context;
		NSString *value1 = [dict objectForKey:key1];
		NSString *value2 = [dict objectForKey:key2];
		return [value1 compare:value2];
	}
	return r;
}

@implementation BSTwitterRequest

@synthesize URL = _URL;
@synthesize parameters = _parameters;
@synthesize requestMethod = _requestMethod;
@synthesize twitterAccessKey = _twitterAccessToken;

- (id)initWithURL:(NSURL *)url parameters:(NSDictionary *)parameters requestMethod:(BSTwitterRequestMethod)requestMethod
{
    if (!(self = [super init])) {
        return nil;
    }
    _URL = url;
    _parameters = parameters;
    _requestMethod = requestMethod;
    
    return self;
}

-(void) performRequestWithJSONHandler:(BSTwitterJSONRequestHandler) handler
{        
    ASIHTTPRequest*  request_ = nil;
    if (_requestMethod == BSTwitterRequestMethodGET) {
        NSURL* url = _URL;
        
        NSMutableDictionary* submitParams = [NSMutableDictionary dictionaryWithDictionary:_parameters];
        NSString* originalQuery = url.query;
        if (originalQuery) {
            NSDictionary* queryParams = [NSURL ab_parseURLQueryString:originalQuery];
            [submitParams addEntriesFromDictionary:queryParams];
        }
        
        NSMutableDictionary *encodedParameters = [NSMutableDictionary dictionary];
        for(NSString *key in submitParams) {
            NSString *value = [submitParams objectForKey:key];
            [encodedParameters setObject:[value ab_RFC3986EncodedString] forKey:[key ab_RFC3986EncodedString]];
        }
        
        NSArray *sortedKeys = [[encodedParameters allKeys] sortedArrayUsingFunction:BSTwitterRequestSortParameter context:(__bridge void*) encodedParameters];

        NSMutableArray *parameterArray = [NSMutableArray array];
        for(NSString *key in sortedKeys) {
            [parameterArray addObject:[NSString stringWithFormat:@"%@=%@", key, [encodedParameters objectForKey:key]]];
        }
        NSString *normalizedParameterString = [parameterArray componentsJoinedByString:@"&"];

        NSString *normalizedURLString = [NSString stringWithFormat:@"%@://%@%@?%@", [url scheme], [url host], [url path],normalizedParameterString];

        request_ = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:normalizedURLString]];
        [request_ setRequestMethod:@"GET"];
    } else {
        ASIFormDataRequest* formRequest = [ASIFormDataRequest requestWithURL:_URL];
        for (NSString* key in _parameters) {
            id value = [_parameters objectForKey:key];
            [formRequest setPostValue:value forKey:key];
        }
        if (_requestMethod == BSTwitterRequestMethodDELETE) {
            [formRequest setRequestMethod:@"DELETE"];
        } else {
            [formRequest setRequestMethod:@"POST"];
        }
        
        request_ = formRequest;
    }
    ASIHTTPRequest __weak* request = request_;
    request.useSessionPersistence = NO;
    request.useKeychainPersistence = NO;
    request.useCookiePersistence = NO;
    [request buildPostBody];
    
    BSTwitterAccessKey* accessToken = self.twitterAccessKey;
    
    NSString* header = OAuthorizationHeader([request url], [request requestMethod], [request postBody], accessToken.consumerKey, accessToken.consumerSecret, accessToken.accessToken, accessToken.accessTokenSecret);
    [request addRequestHeader:@"Authorization" value:header];
    
    [request setCompletionBlock:^{
        NSError* jsonError = nil;
        NSData* jsonData = request.responseData;
        id jsonResult = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
        if (jsonError) {
            handler(nil,jsonError);
            return;
        } else if ([jsonResult isKindOfClass:[NSDictionary class]]) {
            id twitterErrors = [jsonResult objectForKey:@"errors"];
            if ([twitterErrors isKindOfClass:[NSArray class]]) {
                NSError* error = [NSError errorWithTwitterResults:twitterErrors];
                handler(jsonResult,error);
                return;
            }
        }
        handler(jsonResult,nil);
    }];
    
    [request setFailedBlock:^{
        NSError* requestError = request.error;
        if (requestError) {
            handler(nil,requestError);
        }
    }];
    
    [request startAsynchronous];
}


@end
