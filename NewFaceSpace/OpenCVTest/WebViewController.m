//
//  WebViewController.m
//  FaceSpace
//
//  Created by Woodley, Bob on 5/12/13.
//  Copyright (c) 2013 Woodley, Bob. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>

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
    
    NSURL *url=[[NSBundle mainBundle] bundleURL];
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"Loading" ofType:@"html" inDirectory:nil];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL:url];
    
    [self uploadImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)uploadImage {

	NSData *imageData = UIImageJPEGRepresentation(_FaceImage, 90);
	NSString *deviceName = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//	NSString *encodedDeviceName = [NSString stringByAddingPercentEscapesUsingEncoding: deviceName];
	NSString *vendorID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
	NSString *urlStringPrefix = @"http://facefield.org/iosUpload.aspx?devID=";
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

    //NSLog(@"URL is %@", response.URL);    // iosUpload URL
    //NSLog(@"URL is %@", request.URL);     // Carousel.aspx redirect
    
    if (response) {
        NSMutableURLRequest *r = [request mutableCopy];
        // when you get here, request.URL has the redirect response.
        NSString* launchUrl = [[request URL]  absoluteString];
        //NSLog(@"Redirecting to %@", launchUrl);
        int ukey = [self getUKeyFromURL:launchUrl];
        [self saveImageToFaceFieldAlbum:ukey];
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
- (void)saveImageToFaceFieldAlbum:(int) theID {
    // from: http://agilewarrior.wordpress.com/2012/02/06/how-to-save-and-read-metadata-for-images-on-the-iphone/
    ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
    NSMutableDictionary *tiffDictionary = [NSMutableDictionary dictionary];
    NSString *cachedValue = [NSString stringWithFormat:@"FaceFieldID %d", theID];
    [tiffDictionary setValue:cachedValue forKey:(NSString *)kCGImagePropertyTIFFMake];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:tiffDictionary forKey:(NSString *)kCGImagePropertyTIFFDictionary];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSString *albumName = @"AntiFace";
    __weak ALAssetsLibrary *wlibrary = library;
    [al writeImageToSavedPhotosAlbum:[self.FaceImage CGImage]
                            metadata:dict
                     completionBlock:^(NSURL *assetURL, NSError *error) {
                         if (error == nil) {
                             [library addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
                                 if (group == nil) {    // means album was already there. so we have to iterate and find it.
                                     [wlibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                                             usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                                                 
                                                                 if ([albumName compare: [group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame) {
                                                                     [wlibrary assetForURL: assetURL
                                                                               resultBlock:^(ALAsset *asset) {
                                                                                   [group addAsset: asset];
                                                                               } failureBlock:^(NSError *error) {
                                                                                   NSLog(@"Error getting Asset from URL");
                                                                               }];
                                                                 }
                                                             } failureBlock:^(NSError *error) {
                                                                 NSLog(@"Error enumerating albums");
                                                             }];
                                 }
                                 else {                 // album was created and we have a handle to it.
                                     [wlibrary assetForURL: assetURL
                                               resultBlock:^(ALAsset *asset) {
                                                   [group addAsset: asset];
                                               } failureBlock:^(NSError *error) {
                                                   NSLog(@"Error getting Asset from URL");
                                               }];
                                     NSLog(@"Successfully added photo to AntiFace album");
                                 }
                             } failureBlock:^(NSError *error) {
                                 NSLog(@"Error creating AntiFace album");
                             }];
                         } else {
                             NSLog(@"Error saving image.");
                         }
                     }
     ];
    

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
