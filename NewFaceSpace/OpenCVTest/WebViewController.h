//
//  WebViewController.h
//  FaceSpace
//
//  Created by Woodley, Bob on 5/12/13.
//  Copyright (c) 2013 Woodley, Bob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate>
{
    UIImage *_FaceImage;
    NSMutableData *_responseData;
}

@property (nonatomic, retain) UIImage *FaceImage;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *FaceURL;


@end
