//
//  RollViewController.h
//  FaceSpace
//
//  Created by Woodley, Bob on 6/23/13.
//  Copyright (c) 2013 Woodley, Bob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RollViewController : UIViewController
{
//    NSURL *facefieldurl = [[NSURL alloc] initWithString:urlString];
    bool _preventRecursion;
    NSURL *_FaceFieldURL;
}
@property (nonatomic, retain) NSURL *FaceFieldURL;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end
