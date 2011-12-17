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


NSString* const BSTwitterRequestErrorDomain = @"com.basilsalad.BSTwitterFramework.BSTwitterRequestErrorDomain";


NSString* const BSTwitterRequestErrorHTTPCodeKey = @"com.basilsalad.BSTwitterFramework.BSTwitterRequestErrorDomain.BSTwitterRequestErrorHTTPCodeKey";

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
    if (_requestMethod == BSTwitterRequestMethodPOST) {
        ASIFormDataRequest* formRequest = [ASIFormDataRequest requestWithURL:_URL];
        for (NSString* key in _parameters) {
            id value = [_parameters objectForKey:key];
            [formRequest setPostValue:value forKey:key];
        }
        
        [formRequest setRequestMethod:@"POST"];
        request_ = formRequest;

    } else {
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
        
        /// ----
        if (_requestMethod == BSTwitterRequestMethodDELETE) {
            [request_ setRequestMethod:@"DELETE"];
        } else {
            [request_ setRequestMethod:@"GET"];
        }
        
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
            // Twitter responds with an HTML page when the service is down.
            // in those cases, detect the response code
            // http://en.wikipedia.org/wiki/List_of_HTTP_status_codes
            int httpStatus = request.responseStatusCode;
            if (httpStatus == 200) {
                // HTTP/200 -- OK
                // just return the JSON error
                handler(nil,jsonError);
                return;
            }
            
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:4];
            NSInteger errorCode = BSTwitterRequestErrorUnknown;
            NSString* errorMessage = nil;
            switch (httpStatus) {
                case 502: // HTTP 502 "Bad Gateway"
                    // looks like Twitter uses 502 for "Over Capacity" errors
                    errorCode = BSTwitterRequestErrorOverCapacity;
                    errorMessage = NSLocalizedString(@"Twitter is currently over capacity - please try again later", @"Twitter HTTP Error");
                    break;
                case 503: // HTTP 503 "Service Unavailable"
                    errorCode = BSTwitterRequestErrorServiceUnavailable;
                    errorMessage = NSLocalizedString(@"Twitter is currently unavailable - please try again later", @"Twitter HTTP Error");
                    break;
            }
            
            [userInfo setObject:[NSNumber numberWithInt:httpStatus] forKey:BSTwitterRequestErrorHTTPCodeKey];            
            NSURL* url = [request url];
            if (url) {
                [userInfo setObject:url forKey:NSURLErrorKey];
            }
            
            if (errorMessage) {
                [userInfo setObject:errorMessage forKey:NSLocalizedDescriptionKey];
            }            
            [userInfo setObject:jsonError forKey:NSUnderlyingErrorKey];
            
            NSError* returnError =[NSError errorWithDomain:BSTwitterRequestErrorDomain code:errorCode userInfo:userInfo];
            handler(nil,returnError);            
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
