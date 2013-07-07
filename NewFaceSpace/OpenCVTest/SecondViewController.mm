//
//  SecondViewController.m
//  FaceSpace
//
//  Created by Woodley, Bob on 4/25/13.
//  Copyright (c) 2013 Woodley, Bob. All rights reserved. test
//
#import <Foundation/Foundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import "ViewController.h"
#import "SecondViewController.h"
#import "WebViewController.h"
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
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        NSLog(@"SecondView controller was popped");
        [parent startCamera];
    }
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // see: http://stackoverflow.com/questions/9826920/uinavigationcontroller-force-rotate
    //set statusbar to the desired rotation position
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    //present/dismiss viewcontroller in order to activate rotating.
    UIViewController *mVC = [[UIViewController alloc] init];
    [self presentViewController:mVC animated:NO completion:NULL];
    [self dismissViewControllerAnimated:NO completion:NULL];
    
    // the face image is a square... resize the image view.
    double newHeight = _FaceImageView.frame.size.width;
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
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // from: http://agilewarrior.wordpress.com/2012/02/06/how-to-save-and-read-metadata-for-images-on-the-iphone/
    ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
    NSMutableDictionary *tiffDictionary = [NSMutableDictionary dictionary];
    [tiffDictionary setValue:@"FaceFieldID" forKey:(NSString *)kCGImagePropertyTIFFMake];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:tiffDictionary forKey:(NSString *)kCGImagePropertyTIFFDictionary];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSString *albumName = @"FaceField";
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
                                     NSLog(@"Successfully added photo to FaceField album");
                                 }
                             } failureBlock:^(NSError *error) {
                                 NSLog(@"Error creating FaceField album");
                             }];
                         } else {
                             NSLog(@"Error saving image.");
                         }
                     }
     ];

    // ----
    
    NSLog(@"***prepareForSegue: %@", segue.identifier);
    WebViewController *webVC = [segue destinationViewController];
    webVC.FaceImage = self.FaceImage_Histogram;
}
/*
- (IBAction)userTappedSubmitFace:(id)sender {
    NSLog(@"Tapped me.");
    [self showCarouselWebPage];
}
- (void) showCarouselWebPage {
    //NSLog(@"THe URL is %@", theURL);
    WebViewController *webVC =
    [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
    webVC.FaceImage = self.FaceImage_Histogram;
    [self.navigationController pushViewController:webVC animated:YES];
}
 */

@end
