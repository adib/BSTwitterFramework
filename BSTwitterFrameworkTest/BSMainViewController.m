//
//  BSMainViewController.m
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 09-12-11.
//  Copyright (c) 2011 Basil Salad Software. Some rights reserved – refer to the included LICENSE file.
//  http://basil-salad.com
//

#import "BSMainViewController.h"
#import "Secrets.h"
#import "BSTwitterRequest.h"

@implementation BSMainViewController

@synthesize accessToken;
@synthesize accessTokenSecret;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    self.accessToken = [defaults stringForKey:@"accessToken"];
    self.accessTokenSecret = [defaults stringForKey:@"accessTokenSecret"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(BSFlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showInfo:(id)sender
{    
    BSFlipsideViewController *controller = [[BSFlipsideViewController alloc] initWithNibName:@"BSFlipsideViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
}

#pragma mark Event Handlers

-(IBAction) onAuthenticate:(id) sender 
{
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* splashPath = [mainBundle pathForResource:@"sample_splash" ofType:@"html"];
    BSWebAuthViewController* ctrl = [BSWebAuthViewController instantiate];
    ctrl.delegate = self;
    ctrl.consumerKey = BSSampleConsumerKey;
    ctrl.consumerSecret = BSSampleConsumerSecret;
    ctrl.callbackURL = [NSURL URLWithString:BSSampleCallbackURL];
    ctrl.splashURL = [NSURL fileURLWithPath:splashPath];    
    [self presentModalViewController:ctrl animated:YES];
    
}

-(IBAction) onVerifyCredentials:(id)sender
{
    NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
    NSURL* requestURL = [NSURL URLWithString:@"http://api.twitter.com/1/account/verify_credentials.json"];
    NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"false",@"include_entities", nil];

    BSTwitterRequest* request = [[BSTwitterRequest alloc] initWithURL:requestURL parameters:parameters requestMethod:BSTwitterRequestMethodGET];
    request.accessToken = self.accessToken;
    request.accessTokenSecret = self.accessTokenSecret;
    request.consumerKey = BSSampleConsumerKey;
    request.consumerSecret = BSSampleConsumerSecret;
    
    [request performRequestWithJSONHandler:^(id jsonResult, NSError *error) {
        NSLog(@"Error: %@ Result: %@",error,jsonResult); 
        [mainQueue addOperationWithBlock:^{
            if (error) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else {
                NSString* message = [NSString stringWithFormat:@"You are: %@",[jsonResult objectForKey:@"name"]];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }];

    
}


-(IBAction) onShowDirectMessage:(id)sender
{
    NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
    NSURL* requestURL = [NSURL URLWithString:@"http://api.twitter.com/1/direct_messages.json"];
    NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"false",@"include_entities", nil];
    
    BSTwitterRequest* request = [[BSTwitterRequest alloc] initWithURL:requestURL parameters:parameters requestMethod:BSTwitterRequestMethodGET];
    request.accessToken = self.accessToken;
    request.accessTokenSecret = self.accessTokenSecret;
    request.consumerKey = BSSampleConsumerKey;
    request.consumerSecret = BSSampleConsumerSecret;
    
    [request performRequestWithJSONHandler:^(id jsonResult, NSError *error) {
        NSLog(@"Error: %@ Result: %@",error,jsonResult); 
        [mainQueue addOperationWithBlock:^{
            if (error) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else {
                if ([jsonResult isKindOfClass:[NSArray class]]) {
                    NSArray* messages = jsonResult;
                    if ([messages count] > 0) {
                        NSDictionary* entry = [messages objectAtIndex:0];
                        NSString* message = [NSString stringWithFormat:@"Last DM: %@",[entry objectForKey:@"text"]];
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                }
            }
        }];
    }];
}

-(IBAction) onTweet:(id)sender
{
    NSString* text = [NSString stringWithFormat:@"Test tweet at %@",[NSDate date]];
    NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
    NSURL* requestURL = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"];
    NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                text,@"status", nil];
    
    BSTwitterRequest* request = [[BSTwitterRequest alloc] initWithURL:requestURL parameters:parameters requestMethod:BSTwitterRequestMethodPOST];
    request.accessToken = self.accessToken;
    request.accessTokenSecret = self.accessTokenSecret;
    request.consumerKey = BSSampleConsumerKey;
    request.consumerSecret = BSSampleConsumerSecret;
    
    [request performRequestWithJSONHandler:^(id jsonResult, NSError *error) {
        NSLog(@"Error: %@ Result: %@",error,jsonResult); 
        [mainQueue addOperationWithBlock:^{
            if (error) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else {
                if ([jsonResult isKindOfClass:[NSDictionary class]]) {
                    NSDictionary* entry = jsonResult;
                    NSString* message = [NSString stringWithFormat:@"TweetID: %@",[entry objectForKey:@"id_str"]];
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }
        }];
    }];
    
}

#pragma mark BSWebAuthViewController


-(void) webAuthViewControllerDidCancel:(BSWebAuthViewController*) ctrl 
{
    [ctrl dismissModalViewControllerAnimated:YES];
}


-(void) webAuthViewController:(BSWebAuthViewController*)ctrl didCompleteWithResponseDictionary:(NSDictionary*) responseDictionary;
{
    NSLog(@"Access Token:\t%@",ctrl.accessToken);
    NSLog(@"Access Token secret:\t%@",ctrl.accessTokenSecret);

    self.accessToken = ctrl.accessToken;
    self.accessTokenSecret = ctrl.accessTokenSecret;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.accessToken forKey:@"accessToken"];
    [defaults setObject:self.accessTokenSecret forKey:@"accessTokenSecret"];
    [defaults synchronize];

    [ctrl dismissModalViewControllerAnimated:YES];

}

-(void) webAuthViewController:(BSWebAuthViewController*)ctrl didFailWithError:(NSError*) error
{
    NSLog(@"Error :\t%@",error);
    [ctrl dismissModalViewControllerAnimated:YES];
}



@end
