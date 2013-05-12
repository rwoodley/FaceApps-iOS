//
//  SecondViewController.m
//  FaceSpace
//
//  Created by Woodley, Bob on 4/25/13.
//  Copyright (c) 2013 Woodley, Bob. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"
@implementation SecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillDisappear:(BOOL)animated
{
    int currentVCIndex = [self.navigationController.viewControllers indexOfObject:self.navigationController.topViewController];
    ViewController *parent = (ViewController *)[self.navigationController.viewControllers objectAtIndex:currentVCIndex];
    //[parent unwindFromPickerToMain: NULL];
    [parent startCamera];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    double newHeight = _FaceImageView.frame.size.width * (352.0/288.0);
    _FaceImageView.frame = CGRectMake(
                                  _FaceImageView.frame.origin.x,
                                  _FaceImageView.frame.origin.y, _FaceImageView.frame.size.width, newHeight);
    NSLog(@"image h*w = %f,%f", _FaceImageView.frame.size.height, _FaceImageView.frame.size.width);
    self.FaceImageView.image = self.FaceImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)userTappedSubmitFace:(id)sender {
    NSLog(@"Tapped me.");
    [self uploadImage];
}
- (IBAction)uploadImage {
	/*
	 turning the image into a NSData object
	 getting the image back out of the UIImageView
	 setting the quality to 90
     */
	NSData *imageData = UIImageJPEGRepresentation(_FaceImageView.image, 90);
	// setting up the URL to post to
	NSString *urlString = @"http://facespace.apphb.com/iosUpload.aspx";
	
	// setting up the request object now
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
	
	/*
	 add some header info now
	 we always need a boundary when we post a file
	 also we need to set the content type
	 
	 You might want to generate a random boundary.. this is just the same
	 as my output from wireshark on a valid html post
     */
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *contentType1 = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request addValue:contentType1 forHTTPHeaderField: @"Content-Type"];
	
	/*
	 now lets create the body of the post
     */
	NSMutableData *body = [NSMutableData data];
	//[body appendData:[[NSString stringWithFormat:@"rn--%@rn",boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    //NSString *contentDisposition = @"Content-Disposition: form-data; name=\"userfile\"; filename=\"ipodfile.jpg\"\r\n";
    //[body appendData:[contentDisposition dataUsingEncoding:NSUTF8StringEncoding]];

    //NSString *contentType2 = @"Content-Type: application/octet-streamrnrn";
	//[body appendData:[contentType2 dataUsingEncoding:NSUTF8StringEncoding]];
    
	[body appendData:[NSData dataWithData:imageData]];
	//[body appendData:[[NSString stringWithFormat:@"rn--%@--rn",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
	
	// now lets make the connection to the web
    /*
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError ];
	NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
	
	NSLog(returnString);
     */
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
//    NSURLRequest *newRequest = request;
//    NSLog(@"URL is %@", response.URL);
//    NSLog(@"URL is %@", request.URL);
    
    if (response) {
        NSMutableURLRequest *r = [request mutableCopy];
        // when you get here, request.URL has the redirect response.
        NSString* launchUrl = [[request URL]  absoluteString];
        NSLog(@"Redirecting to %@", launchUrl);
       [[UIApplication sharedApplication] openURL:[request URL]];
        [r setURL: [request URL]];
        return r;
    }
    else
        return request;
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
