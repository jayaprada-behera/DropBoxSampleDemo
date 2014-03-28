//
//  WARootViewController.m
//  StoreSampleDemo
//
//  Created by Jayaprada Behera on 25/03/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import "WARootViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface WARootViewController ()
- (void)updateButtons;

@end

@implementation WARootViewController
@synthesize linkButton;
@synthesize photoViewController;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.title = @"Link Account";
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didPressLink {
    if (![[DBSession sharedSession] isLinked]) {
		[[DBSession sharedSession] linkFromController:self];
    } else {
        [[DBSession sharedSession] unlinkAll];
        [[[UIAlertView alloc]
           initWithTitle:@"Account Unlinked!" message:@"Your dropbox account has been unlinked"
           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
         show];
        [self updateButtons];
    }
}

- (IBAction)didPressPhotos {
    [self.navigationController pushViewController:photoViewController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self updateButtons];
}
//https://www.dropbox.com/developers/apps/info/gw1yol98j7rniqr
//http://www.raywenderlich.com/51127/nsurlsession-tutorial
//https://www.dropbox.com/developers/core/sdks/ios
//http://stackoverflow.com/questions/19377670/uploadedfile-not-called

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                               initWithTitle:@"Photos" style:UIBarButtonItemStylePlain
                                               target:self action:@selector(didPressPhotos)];
    
    self.title = @"Link Account";
}

- (void)viewDidUnload {
    linkButton = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return toInterfaceOrientation == UIInterfaceOrientationPortrait;
    } else {
        return YES;
    }
}


#pragma mark private methods


- (void)updateButtons {
    NSString* title = [[DBSession sharedSession] isLinked] ? @"Unlink Dropbox" : @"Link Dropbox";
    [linkButton setTitle:title forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem.enabled = [[DBSession sharedSession] isLinked];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
