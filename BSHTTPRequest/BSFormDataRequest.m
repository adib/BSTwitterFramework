//
//  BSFormDataRequest.m
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 21-01-12.
//  Copyright (c) 2012 Basil Salad Software. Some rights reserved – refer to the included LICENSE file.
//  http://basil-salad.com

#import "BSFormDataRequest.h"

@interface ASIHTTPRequest (MainThreadMethods)
- (void)requestStarted;
- (void) reportFinished;
- (void)requestRedirected;
- (void)requestWillRedirectToURL:(NSURL *)newURL;
- (void)passOnReceivedData:(NSData *)data;
@end

@implementation BSFormDataRequest

-(void) shuntToBackground:(void (^)()) block
{
    if ([NSThread isMainThread]) {
        [[[self class] sharedQueue] addOperationWithBlock:^{
            @synchronized(self) {
                block();
            }
        }];
    } else {
        block();
    }
}

- (void)requestStarted
{
    void (^callSuperBlock)() = ^{
        [super requestStarted];
    };
    [self shuntToBackground:callSuperBlock];
}

- (void)requestRedirected
{
    void (^callSuperBlock)() = ^{
        [super requestRedirected];
    };
    [self shuntToBackground:callSuperBlock];
}

- (void)requestReceivedResponseHeaders:(NSMutableDictionary *)receivedResponseHeaders
{
    void (^callSuperBlock)() = ^{
        [super requestReceivedResponseHeaders:responseHeaders];
    };
    [self shuntToBackground:callSuperBlock];
}


- (void)requestWillRedirectToURL:(NSURL *)newURL
{
    void (^callSuperBlock)() = ^{
        [super requestWillRedirectToURL:newURL];
    };
    [self shuntToBackground:callSuperBlock];
}


- (void)reportFinished
{
    void (^callSuperBlock)() = ^{
        [super reportFinished];
    };
    [self shuntToBackground:callSuperBlock];
}

- (void)passOnReceivedData:(NSData *)data
{
    void (^callSuperBlock)() = ^{
        [super passOnReceivedData:data];
    };
    [self shuntToBackground:callSuperBlock];
}


@end
