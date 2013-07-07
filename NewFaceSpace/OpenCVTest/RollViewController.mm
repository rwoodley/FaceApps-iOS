//
//  RollViewController.m
//  FaceSpace
//
//  Created by Woodley, Bob on 6/23/13.
//  Copyright (c) 2013 Woodley, Bob. All rights reserved.
//
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

#import "ViewController.h"
#import "WebViewController.h"
#import "RollViewController.h"

@interface RollViewController ()

@end

@implementation RollViewController

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
        NSLog(@"RollViewController was popped");
        [parent startCamera];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;

        imagePicker.delegate = self;
        //[self presentModalViewController: imagePicker animated: YES];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:NULL];
//    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
//    _imageView.image = image;
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSURL *assetURL = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    [library assetForURL: assetURL
              resultBlock:^(ALAsset *asset) {
                  NSDictionary *metadata = asset.defaultRepresentation.metadata;
                  
                  //for(id key in metadata) NSLog(@"key=%@ value=%@", key, [metadata objectForKey:key]);
                  // We're caching the ID in the TIFF dictionary entry with this key: kCGImagePropertyTIFFMake
                  NSDictionary *tiffDictionary = [metadata objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
                  NSString *ourCachedValue = [tiffDictionary objectForKey:(NSString *)kCGImagePropertyTIFFMake];
                  if (ourCachedValue != NULL) {
                      NSString *value = [ourCachedValue substringWithRange:NSMakeRange(0, 11)];
                      if ([value isEqualToString:@"FaceFieldID"]) {
                          NSString *idString =[ourCachedValue substringWithRange:NSMakeRange(11, [ourCachedValue length]-11)];
                          NSLog(@"idString: %@", idString);
                          /*
                          WebViewController *webVC =
                          [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
                          webVC.FaceImage = self.FaceImage_Histogram;
                          [self.navigationController pushViewController:webVC animated:YES];
                           */
                      }
                      else
                          NSLog(@"!!!NOT FOUND!!!");
                  }
                  else
                      NSLog(@"!!!NOT FOUND!!!");
              } failureBlock:^(NSError *error) {
                  NSLog(@"Error getting Asset from URL");
              }];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
