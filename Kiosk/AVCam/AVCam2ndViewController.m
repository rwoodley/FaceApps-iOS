//
//  AVCam2ndViewController.m
//  AVCam
//
//  Created by Robert Woodley on 5/1/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "AVCam2ndViewController.h"

@interface AVCam2ndViewController ()

@end

@implementation AVCam2ndViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self uploadImage];
}
- (IBAction)uploadImage {
    
	NSData *imageData = UIImageJPEGRepresentation(_FaceImage, 1);
	NSString *deviceName = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //	NSString *encodedDeviceName = [NSString stringByAddingPercentEscapesUsingEncoding: deviceName];
	NSString *vendorID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
	NSString *urlStringPrefix = @"http://facefield.org/iosUpload.aspx?redirectionRequest=SynthFace&devID=";
    NSString *urlString = [[[urlStringPrefix stringByAppendingString:vendorID] stringByAppendingString:@"&devName="] stringByAppendingString:  deviceName];
    NSLog(@"Posting to %@", urlString);
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

- (void)viewWillAppear:(BOOL)animated
{
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
//    [self.navigationController setToolbarHidden:NO animated:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden
{
	return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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
    // This routine is called twice, once with a null response that (i presume) represents the initial upload
    // The 2nd time, the response indicates that we are ready to redirect.
    NSLog(@"URL is %@", response.URL);    // iosUpload URL
    NSLog(@"URL is %@", request.URL);     // Carousel.aspx redirect
    
    if (response) {
        NSMutableURLRequest *newRequest = [request mutableCopy];
        // when you get here, request.URL has the redirect response.
        NSString* launchUrl = [[request URL]  absoluteString];
        //NSLog(@"Redirecting to %@", launchUrl);
        //int ukey = [self getUKeyFromURL:launchUrl];
        [self showCarouselWebPage:launchUrl];
        [newRequest setURL: [request URL]];
        return newRequest;
    }
    else
        return request;
}
- (void) showCarouselWebPage:(NSString *) theURL {
    NSLog(@"Redirecting to %@", theURL);
    NSURL *url = [[NSURL alloc] initWithString:theURL];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.myWebView loadRequest:request];
    
}
- (int) getUKeyFromURL: (NSString *) theURL {
    if(!theURL||[theURL length]==0) return -1;
    
    for(NSString* parameter in [theURL componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"?&"]]) {
        NSRange range = [parameter rangeOfString:@"="];
        if(range.location!=NSNotFound) {
            NSString *key = [[parameter substringToIndex:range.location] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            NSLog(@"Found key %@",key);
            if (![[key uppercaseString] isEqualToString:@"UKEY"]) continue;
            NSString *value = [[parameter substringFromIndex:range.location+range.length] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            int retval = value.intValue;
            
            NSLog(@"Found value %d",retval);
            return retval;
        }
    }
    return -1;
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
