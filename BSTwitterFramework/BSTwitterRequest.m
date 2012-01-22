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

NSString* const BSTwitterRequestErrorRetryAfterKey = @"com.basilsalad.BSTwitterFramework.BSTwitterRequestErrorDomain.BSTwitterRequestErrorRetryAfterKey";


@implementation BSTwitterRequest

@synthesize URL = _URL;
@synthesize parameters = _parameters;
@synthesize requestMethod = _requestMethod;
@synthesize twitterAccessKey = _twitterAccessToken;

@synthesize rateLimitLimit = _rateLimitLimit;
@synthesize rateLimitRemaining = _rateLimitRemaining;
@synthesize rateLimitReset = _rateLimitReset;
@synthesize rateLimitOK = _rateLimitOK;

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

-(void) updateRateLimitsFromRequest:(ASIHTTPRequest*) request
{
    NSNull* null = [NSNull null];
    
    NSDictionary* responseHeaders = request.responseHeaders;
    if (!responseHeaders) {
        return;
    }
    
    _rateLimitOK = YES;

    id rateLimit = [responseHeaders objectForKey:@"X-RateLimit-Limit"];
    if (rateLimit && rateLimit != null) {
        _rateLimitLimit = [rateLimit intValue];        
    } else {
        _rateLimitOK = NO;
    }
    
    id rateRemaining = [responseHeaders objectForKey:@"X-RateLimit-Remaining"];
    if (rateRemaining && rateRemaining != null) {
        _rateLimitRemaining = [rateRemaining intValue];
    } else {
        _rateLimitOK = NO;
    }
    
    id rateReset = [responseHeaders objectForKey:@"X-RateLimit-Reset"];
    if (rateReset && rateReset != null) {
        _rateLimitReset = [rateReset longLongValue];
    } else {
        _rateLimitOK = NO;
    }
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
    
    ASIHTTPRequest *const request = request_;
    request.useSessionPersistence = NO;
    request.useKeychainPersistence = NO;
    request.useCookiePersistence = NO;
    [request buildPostBody];
    
    BSTwitterAccessKey* accessToken = self.twitterAccessKey;
    
    NSString* header = OAuthorizationHeader([request url], [request requestMethod], [request postBody], accessToken.consumerKey, accessToken.consumerSecret, accessToken.accessToken, accessToken.accessTokenSecret);
    [request addRequestHeader:@"Authorization" value:header];
    
    void (^completionBlock)() = ^{
        [self updateRateLimitsFromRequest:request];
        const int httpStatusOK = 200;
        NSError* jsonError = nil;
        NSData* jsonData = request.responseData;
        if (!jsonData) {
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
            [userInfo setObject:NSLocalizedString(@"Empty response from Twitter", @"Twitter request") forKey:NSLocalizedDescriptionKey];
            NSURL* requestURL = [request url];
            if (requestURL) {
                [userInfo setObject:requestURL forKey:NSURLErrorKey];
            }
            NSError* error = [NSError errorWithDomain:BSTwitterErrorDomain code:BSTwitterRequestErrorEmptyReply userInfo:userInfo];
            handler(nil,error);
            return;
        }
        id jsonResult = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
        int httpStatus = request.responseStatusCode;

        // Twitter responds with an HTML page when the service is down.
        // in those cases, detect the response code
        // http://en.wikipedia.org/wiki/List_of_HTTP_status_codes

        if (jsonError || httpStatus != httpStatusOK) {
            if (httpStatus == httpStatusOK) {
                // HTTP/200 -- OK
                // just return the JSON error
                handler(nil,jsonError);
                return;
            }
            
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:6];
            NSInteger errorCode = httpStatus;
            NSString* errorMessage = nil;
            NSError* returnError = nil;
            switch (httpStatus) {
                case BSTwitterRequestErrorOverCapacity: // HTTP 502 "Bad Gateway"
                    // looks like Twitter uses 502 for "Over Capacity" errors
                    errorMessage = NSLocalizedString(@"Twitter is currently over capacity - please try again later", @"Twitter HTTP Error");
                    break;
                case BSTwitterRequestErrorServiceUnavailable: // HTTP 503 "Service Unavailable"
                    errorMessage = NSLocalizedString(@"Twitter is currently unavailable - please try again later", @"Twitter HTTP Error");
                    break;
                case BSTwitterRequestErrorRateLimitedAPI:
                    errorMessage = NSLocalizedString(@"You are being rate-limited by Twitter - please try again some time later.", @"Twitter HTTP Error");
                    break;
                case BSTwitterRequestErrorRateLimitedSearch: {
                    errorMessage = NSLocalizedString(@"Your searches have been rate-limited by Twitter - please try again some time later.", @"Twitter HTTP Error");
                    // Rate-limiting https://dev.twitter.com/docs/rate-limiting
                    int retryAfter = [[[request responseHeaders] objectForKey:@"Retry-After"] intValue];
                    if (retryAfter > 0) {
                        [userInfo setObject:[NSNumber numberWithInt:retryAfter] forKey:BSTwitterRequestErrorRetryAfterKey];
                    }
                }  break;
                default:
                    errorCode = BSTwitterRequestErrorUnknown;
                    if ([jsonResult isKindOfClass:[NSDictionary class]]) {
                        id twitterErrors = [jsonResult objectForKey:@"errors"];
                        if ([twitterErrors isKindOfClass:[NSArray class]]) {
                            returnError = [NSError errorWithTwitterResults:twitterErrors];
                        }
                        // singular error for saved search
                        // example:
                        // https://dev.twitter.com/docs/using-search
                        NSString* twitterErrorMessage = [jsonResult objectForKey:@"error"];
                        if (twitterErrorMessage) {
                            errorMessage = twitterErrorMessage;
                        }
                    }
                break;
                    
            }
            
            if (!returnError) {
                [userInfo setObject:[NSNumber numberWithInt:httpStatus] forKey:BSTwitterRequestErrorHTTPCodeKey];            
                NSURL* url = [request url];
                if (url) {
                    [userInfo setObject:url forKey:NSURLErrorKey];
                }
                
                if (errorMessage) {
                    [userInfo setObject:errorMessage forKey:NSLocalizedDescriptionKey];
                }            
                if (jsonError) {
                    [userInfo setObject:jsonError forKey:NSUnderlyingErrorKey];
                }
                
                returnError = [NSError errorWithDomain:BSTwitterRequestErrorDomain code:errorCode userInfo:userInfo];
            }
            
            handler(jsonResult,returnError);            
            return;
        }         
        handler(jsonResult,nil);
    };
    
    void (^failedBlock)() = ^{
        [self updateRateLimitsFromRequest:request];
        NSError* requestError = request.error;
        if (requestError) {
            handler(nil,requestError);
        }
    };
    NSOperationQueue* sharedQueue = [[request class] sharedQueue];
    [request setCompletionBlock:^{
        [sharedQueue addOperationWithBlock:completionBlock];          
    }];
    
    [request setFailedBlock:^{
        [sharedQueue addOperationWithBlock:failedBlock];          
    }];
    
    [request startAsynchronous];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@ URL=%@ rateLimit: %d rateRemaining: %d rateReset: %@>",[self class],_URL,_rateLimitLimit,_rateLimitRemaining,[NSDate dateWithTimeIntervalSince1970:_rateLimitReset]];
}


@end
