//
//  BSHTTPRequest.m
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 21-01-12.
//  Copyright (c) 2012 Basil Salad Software. Some rights reserved – refer to the included LICENSE file.
//  http://basil-salad.com


#import "ASIHTTPRequest.h"

/**
 A subclass of ASIHTTPRequest that calls its delegate methods in a background thread,
 so that it doesn't block processing
 */
@interface BSHTTPRequest : ASIHTTPRequest

@end
