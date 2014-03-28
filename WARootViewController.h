//
//  WARootViewController.h
//  StoreSampleDemo
//
//  Created by Jayaprada Behera on 25/03/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

//@class DBRestClient;

@interface WARootViewController : UIViewController
{
    UIButton* linkButton;
    UIViewController* photoViewController;
//	DBRestClient* restClient;

}
- (IBAction)didPressLink;

@property (nonatomic, retain) IBOutlet UIButton* linkButton;
@property (nonatomic, retain) UIViewController* photoViewController;

@end
