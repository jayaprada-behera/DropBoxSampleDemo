//
//  WAAppDelegate.m
//  DropBoxSampleDemo
//
//  Created by Jayaprada Behera on 25/03/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import "WAAppDelegate.h"
#import "WARootViewController.h"
#import "WAPhotoViewController.h"

#import <DropboxSDK/DropboxSDK.h>

#define APP_KEY          @"<APP_Key>"
#define APP_SECRET_KEY   @"<APP_SECRET_KEY>"
//Mention this APP_key in info .plist

/*
 <key>CFBundleURLTypes</key>
 <array>
 <dict>
 <key>CFBundleURLSchemes</key>
 <array>
 <string>db-APP_KEY</string>
 </array>
 </dict>

 */
@interface WAAppDelegate () <DBSessionDelegate, DBNetworkRequestDelegate>
{
    UINavigationController *navigationController;
    WARootViewController *rootViewController;
	NSString *relinkUserId;
    
}
@end
@implementation WAAppDelegate
@synthesize window;
//
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    //    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[WARootViewController alloc]initWithNibName:@"WARootViewController" bundle:nil]];
    
   	// Look below where the DBSession is created to understand how to use DBSession in your app
    NSString *root = kDBRootDropbox; // Should be set to either kDBRootAppFolder or kDBRootDropbox
    
	NSString* errorMsg = nil;
	if ([APP_KEY rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
		errorMsg = @"Make sure you set the app key correctly in WAAppDelegate.m";
	} else if ([APP_SECRET_KEY rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
		errorMsg = @"Make sure you set the app secret correctly in WAAppDelegate.m";
	} else if ([root length] == 0) {
		errorMsg = @"Set your root to use either App Folder of full Dropbox";
	} else {
		NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
		NSData *plistData = [NSData dataWithContentsOfFile:plistPath];
		NSDictionary *loadedPlist =
        [NSPropertyListSerialization
         propertyListFromData:plistData mutabilityOption:0 format:NULL errorDescription:NULL];
		NSString *scheme = [[[[loadedPlist objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
		if ([scheme isEqual:@"db-APP_KEY"]) {
			errorMsg = @"Set your URL scheme correctly in StoreSampleDemo-Info.plist";
		}
	}
	
	DBSession* session =
    [[DBSession alloc] initWithAppKey:APP_KEY appSecret:APP_SECRET_KEY root:root];
	session.delegate = self; // DBSessionDelegate methods allow you to handle re-authenticating
	[DBSession setSharedSession:session];
	
	[DBRequest setNetworkRequestDelegate:self];
    
	if (errorMsg .length > 0) {
		[[[UIAlertView alloc]
          initWithTitle:@"Error Configuring Session" message:errorMsg
          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
	}
    
    [self.window addSubview:navigationController.view];

    if ([[DBSession sharedSession] isLinked]) {
        navigationController = [[UINavigationController alloc] initWithRootViewController:[[WAPhotoViewController alloc] initWithNibName:@"WAPhotoViewController" bundle:nil]];
        
    }else{
        navigationController = [[UINavigationController alloc] initWithRootViewController:[[WARootViewController alloc] initWithNibName:@"WARootViewController" bundle:nil]];
    }
    
	
	NSURL *launchURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
	NSInteger majorVersion =
    [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
	if (launchURL && majorVersion < 4) {
		// Pre-iOS 4.0 won't call application:handleOpenURL; this code is only needed if you support
		// iOS versions 3.2 or below
		[self application:application handleOpenURL:launchURL];
		return NO;
	}
    self.window.rootViewController = navigationController;

    // Add the navigation controller's view to the window and display.
    [self.window makeKeyAndVisible];
    
    return YES;
    
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	NSLog(@"URL %@",[url absoluteString]);
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    
    if ([[DBSession sharedSession] handleOpenURL:url]) {
		if ([[DBSession sharedSession] isLinked]) {
            WAPhotoViewController *photoVC = nil;
            photoVC = [[WAPhotoViewController alloc] initWithNibName:@"WAPhotoViewController" bundle:nil];
            
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:photoVC];
            self.window.rootViewController = nav;
            
		}
		return YES;
	}
	
	return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark -
#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId {
	relinkUserId = userId ;
	[[[UIAlertView alloc]
      initWithTitle:@"Dropbox Session Ended" message:@"Do you want to relink?" delegate:self
      cancelButtonTitle:@"Cancel" otherButtonTitles:@"Relink", nil]
	 show];
}


#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index {
	if (index != alertView.cancelButtonIndex) {
		[[DBSession sharedSession] linkUserId:relinkUserId fromController:rootViewController];
	}
	relinkUserId = nil;
}


#pragma mark -
#pragma mark DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
	outstandingRequests++;
	if (outstandingRequests == 1) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
}

- (void)networkRequestStopped {
	outstandingRequests--;
	if (outstandingRequests == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}

@end
