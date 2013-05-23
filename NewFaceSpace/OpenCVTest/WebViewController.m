//
//  WebViewController.m
//  FaceSpace
//
//  Created by Woodley, Bob on 5/12/13.
//  Copyright (c) 2013 Woodley, Bob. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    // Hack to force this to be in landscape mode:
    // see: http://stackoverflow.com/questions/9826920/uinavigationcontroller-force-rotate
    //set statusbar to the desired rotation position
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
    //present/dismiss viewcontroller in order to activate rotating.
    UIViewController *mVC = [[UIViewController alloc] init];
    [self presentViewController:mVC animated:NO completion:NULL];
    [self dismissViewControllerAnimated:NO completion:NULL];
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"Loading" ofType:@"html" inDirectory:nil];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL:nil];
    
    [self uploadImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)uploadImage {

	NSData *imageData = UIImageJPEGRepresentation(_FaceImage, 90);
	NSString *urlString = @"http://facespace.apphb.com/iosUpload.aspx";
	
	// setting up the request object now
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
	
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *contentType1 = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request addValue:contentType1 forHTTPHeaderField: @"Content-Type"];
	
	NSMutableData *body = [NSMutableData data];
    
	[body appendData:[NSData dataWithData:imageData]];

	[request setHTTPBody:body];
	
    NSURLConnection *conn = [[NSURLConnection alloc] init];
    (void)[conn initWithRequest:request delegate:self];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}
- (NSURLRequest *)connection:(NSURLConnection *)connection
             willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{

    NSLog(@"URL is %@", response.URL);
    NSLog(@"URL is %@", request.URL);
    
    if (response) {
        NSMutableURLRequest *r = [request mutableCopy];
        // when you get here, request.URL has the redirect response.
        NSString* launchUrl = [[request URL]  absoluteString];
        NSLog(@"Redirecting to %@", launchUrl);
        //[[UIApplication sharedApplication] openURL:[request URL]];
        [self showCarouselWebPage:launchUrl];
        [r setURL: [request URL]];
        return r;
    }
    else
        return request;
}
- (void) showCarouselWebPage:(NSString *) theURL {
    //NSLog(@"Redirecting to %@", theURL);

    NSURL *url = [[NSURL alloc] initWithString:theURL];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];

}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}


@end
