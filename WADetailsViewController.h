//
//  WADetailsViewController.h
//  StoreSampleDemo
//
//  Created by Jayaprada Behera on 27/03/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import <DropboxSDK/DropboxSDK.h>

@interface WADetailsViewController : UIViewController
@property(strong,nonatomic)NSMutableArray *photoArray;
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;
@property(nonatomic,strong)NSMutableArray *urlArray;
//@property(nonatomic,strong)DBRestClient *restClient;

@end
