//
//  WAPhotoViewController.m
//  StoreSampleDemo
//
//  Created by Jayaprada Behera on 25/03/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import "WAPhotoViewController.h"
#import "WADetailsViewController.h"
#import "WARootViewController.h"

#import <DropboxSDK/DropboxSDK.h>
#import <stdlib.h>
#import <AssetsLibrary/ALAsset.h>

//https://www.dropbox.com/developers/core/docs#authentication-for-mobile-devices
//https://www.dropbox.com/developers/core/start/ios

@interface WAPhotoViewController ()<DBRestClientDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray* urlArray;
    NSMutableArray* photoPaths;
    NSString* photosHash;
    NSString* currentPhotoPath;
    BOOL working;
    DBRestClient* restClient;
    NSMutableArray* newPhotoPaths;
    NSMutableArray* subPhotoPaths;
    
    BOOL isSubFolderTapped;
    
    __weak IBOutlet UITableView *myTableView;
    __weak IBOutlet UIActivityIndicatorView *spinner;
    __weak IBOutlet UIButton *nextButton;
    __weak IBOutlet UIImageView *imageView;
    
    UIBarButtonItem *uploadFileBarButton;
    UIBarButtonItem *refreshBarButton;
    UIBarButtonItem *signoutBarButton;
    UIBarButtonItem *downloadBarButton;
    
}

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, readonly) DBRestClient* restClient;

- (IBAction)didPressRandomPhoto:(id)sender;
@end

@implementation WAPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!working && !imageView.image) {
        [self didPressRandomPhoto:nil];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isSubFolderTapped = NO;
    
    myTableView.delegate = self;
    myTableView.dataSource = self;
    urlArray = [[NSMutableArray alloc] init];
    newPhotoPaths = [NSMutableArray new];
    subPhotoPaths = [NSMutableArray new];
    photoPaths = [NSMutableArray new];
    
    self.title = @"Random Photo";
    
    refreshBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonTapped:)];
    
    uploadFileBarButton  = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(uploadFileButtonTapped:)];
    downloadBarButton = [[UIBarButtonItem alloc] initWithTitle:@"V" style:UIBarButtonItemStylePlain target:self action:@selector(downloadButtonTouchUpInside:)];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:refreshBarButton,uploadFileBarButton, nil]];
    
    signoutBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign out" style:UIBarButtonItemStylePlain target:self action:@selector(signoutButtonTouchUpInside:)];
    self.navigationItem.leftBarButtonItem = signoutBarButton;
    
    self.view.backgroundColor = [UIColor grayColor];
    // Do any additional setup after loading the view from its nib.
}
-(void)refreshButtonTapped:(id)sender{
    [self didPressRandomPhoto:nil];
}
-(IBAction)uploadFileButtonTapped:(id)sender{
    
    //we can upload file from UIImagePickerController .DOne in GoogleDrive Sample
    
    NSString *filename = @"DSC_0568.jpg";
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *localPath = [mainBundle pathForResource: @"DSC_0568" ofType:@"jpg"];
    NSString *destDir = @"/Photos";
    
    [[self restClient] uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
    
}
-(IBAction)downloadButtonTouchUpInside:(id)sender{
    
    NSString *fileName = @"";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    //    [self.restClient loadFile:dropboxPath intoPath:localPath];
    
}
-(IBAction)signoutButtonTouchUpInside:(id)sender{
    
    [[DBSession sharedSession] unlinkAll];
    restClient = nil;

    WARootViewController *rootVC = [[WARootViewController alloc] initWithNibName:@"WARootViewController" bundle:nil];
    
    [self.navigationController presentViewController:rootVC animated:YES completion:nil];
    
}

#pragma mark DBRestClientDelegate methods

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
    
    photosHash = metadata.hash;
    
    NSArray* validExtensions = [NSArray arrayWithObjects:@"jpg", @"jpeg",@"png",@"txt",@"pdf",@"doc",@"mp3",@"mp4", nil];

    [subPhotoPaths removeAllObjects];
    
    [photoPaths removeAllObjects];
    
    if (!isSubFolderTapped) {
        
        [newPhotoPaths removeAllObjects];
    }
    
    for (DBMetadata* child in metadata.contents) {
        
        NSString* extension = [[child.path pathExtension] lowercaseString];
        
        
        //adding all files and folders
  
        if (isSubFolderTapped) {
            
            if (!child.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound) {
                [photoPaths addObject:child.path];
            }
            
            [subPhotoPaths addObject:child.filename];
            
        }else{
            
            [newPhotoPaths addObject:child.filename];
            
        }
        
        //for particular type of file like image or text or PDF
        
        //        NSString* extension = [[child.path pathExtension] lowercaseString];
        //
        //        if (child.isDirectory) {
        //            NSLog(@"Its a folder in home of drop box");
        //
        //        }
    }
    
    if (isSubFolderTapped) {
        [urlArray removeAllObjects];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        for (int i = 0; i < photoPaths.count; i++) {
            
            NSString *fileName = [[[photoPaths objectAtIndex:i] componentsSeparatedByString:@"/"] lastObject];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
            
            [self.restClient loadThumbnail:[photoPaths objectAtIndex:i] ofSize:@"iphone_bestfit" intoPath:filePath];
        }
    }
    isSubFolderTapped = NO;
    //    photoPaths = newPhotoPaths;
    [myTableView reloadData];
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
    [self loadRandomPhoto];
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
    NSLog(@"restClient:loadMetadataFailedWithError: %@", [error localizedDescription]);
    [self displayError];
    [self setWorking:NO];
}

- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)destPath {
//    [self setWorking:NO];
    
 NSURL *outputURL= [[NSURL alloc] initFileURLWithPath:destPath];
    [urlArray addObject:outputURL];
//    [self pushVC];
    
//    imageView.image = [UIImage imageWithContentsOfFile:destPath];
    
    //    NSURL *outputURL= [[NSURL alloc] initFileURLWithPath:destPath];
    //
    //    NSData *data = [NSData dataWithContentsOfURL:outputURL];
    //
    //    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    //
    //    NSDictionary *dict;
    //    [library writeImageDataToSavedPhotosAlbum:data metadata:dict completionBlock:^(NSURL *assetURL, NSError *error) {
    //
    //        if (error) {
    //            NSLog(@"%@",[error description]);
    //        }else {
    //            NSLog(@"Succesfully saved to Photos Album");
    //        }
    //    }];
    
    
}

-(void)pushVC{
    
    WADetailsViewController *detailVC = [[WADetailsViewController alloc] initWithNibName:@"WADetailsViewController" bundle:nil];
    detailVC.photoArray = subPhotoPaths;
    detailVC.urlArray = urlArray;
    
    [self.navigationController pushViewController:detailVC animated:YES];

}

- (void)restClient:(DBRestClient*)client loadThumbnailFailedWithError:(NSError*)error {

//    [self setWorking:NO];
    [self displayError];
    NSLog(@"Error:%@",[error description]);
    
}


#pragma mark private methods

- (IBAction)didPressRandomPhoto:(id)sender {
    
    [self setWorking:YES];
    
    NSString *photosRoot = nil;
    
    if ([DBSession sharedSession].root == kDBRootDropbox) {
        photosRoot = @"/";//can specify any folder like /Photos,/Public etc
    }
    
    //    else {
    //        photosRoot = @"/";
    //    }

    [self.restClient loadMetadata:photosRoot withHash:photosHash];
}


- (NSString*)photoPath {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"photo.jpg"];
}

- (void)displayError {
    [[[UIAlertView alloc]
      initWithTitle:@"Error Loading Photo" message:@"There was an error loading your photo."
      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
}

- (void)setWorking:(BOOL)isWorking {
    if (working == isWorking) return;
    working = isWorking;
    
    if (working) {
        [spinner startAnimating];
    } else {
        [spinner stopAnimating];
    }
    nextButton.enabled = !working;
}

- (DBRestClient*)restClient {
    if (restClient == nil) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return newPhotoPaths.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [newPhotoPaths objectAtIndex:indexPath.row];
    
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    isSubFolderTapped = YES;
    
    NSString *metaData =[NSString stringWithFormat:@"/%@", [newPhotoPaths objectAtIndex:indexPath.row]];
    
    [self.restClient loadMetadata:metaData withHash:photosHash];
    
}

#pragma mark -  DBRestClient Upload File

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
}


#pragma mark -  DBRestClient Download File

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
       contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
    
    NSLog(@"File loaded into path: %@", localPath);
    
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    NSLog(@"There was an error loading the file: %@", error);
}



- (void)loadRandomPhoto {
    if ([photoPaths count] == 0) {
        
        NSString *msg = nil;
        if ([DBSession sharedSession].root == kDBRootDropbox) {
            msg = @"Put .jpg photos in your Photos folder to use this aap!";
        } else {
            msg = @"Put .jpg photos in your app's App folder to use this aap!";
        }
        
        [[[UIAlertView alloc]
          initWithTitle:@"No Photos!" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
        
        [self setWorking:NO];
    } else {
        NSString* photoPath;
        if ([photoPaths count] == 1) {
            photoPath = [photoPaths objectAtIndex:0];
            if ([photoPath isEqual:currentPhotoPath]) {
                [[[UIAlertView alloc]
                  initWithTitle:@"No More Photos" message:@"You only have one photo to display."
                  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
                
                [self setWorking:NO];
                return;
            }
        } else {
            // Find a random photo that is not the current photo
            do {
                srandom(time(NULL));
                NSInteger index =  random() % [photoPaths count];
                photoPath = [photoPaths objectAtIndex:index];
            } while ([photoPath isEqual:currentPhotoPath]);
        }
        
        currentPhotoPath = photoPath ;
        
        [self.restClient loadThumbnail:currentPhotoPath ofSize:@"iphone_bestfit" intoPath:[self photoPath]];
    }
}
-(void)dealloc{

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
