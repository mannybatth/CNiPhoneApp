//
//  CreatePostViewController.m
//  CNiPhoneApp
//
//  Created by Manny on 3/6/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "CreatePostViewController.h"
#import "VisibilitySettingsViewController.h"
#import "HPGrowingTextView.h"
#import "MWPhotoBrowser.h"
#import "UIView+GCLibrary.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD.h"
#import "Tools.h"
#import "PostStore.h"
#import "UIAlertView+Blocks.h"
#import "UIActionSheet+Blocks.h"
#import "TSMessage.h"
#import "CNNavigationHelper.h"
#import "YoutubeSearchViewController.h"
#import "BaseNavigationController.h"
#import "UIButton+AFNetworking.h"

#define POST_PICTURE_THUMBNAIL_SIZE 110
#define POST_PICTURE_THUMBNAIL_SPACING 6

@interface CreatePostViewController () <HPGrowingTextViewDelegate, MWPhotoBrowserDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, YoutubeSearchDelegate, VisibilitySettingsDelegate>
{
    CGRect keyboardFrame;
    NSMutableArray *videos;
    NSMutableArray *photos;
    NSMutableArray *thumbs;
    NSMutableArray *previousSelections;
    NSMutableArray *selections;
    NSMutableArray *attachedPhotos;
    ALAssetsLibrary *assetLibrary;
    NSMutableArray *assets;
    UIImagePickerController *mediaPicker;
    MWPhotoBrowser *browser;
    
    NSMutableArray *uploadedImgsId;
    NSInteger currentUploadIndex;
    NSOperation *currentOperation;
    
    MBProgressHUD *publishingHUD;
    
    NSArray *visibilitySettingsTitles;
    NSArray *visibilitySettingsIcons;
    NSArray *visibilitySettingsValues;
}

@property (nonatomic, strong) IBOutlet UIScrollView *masterScrollView;
@property (nonatomic, strong) IBOutlet UIButton *visibleToBtn;
@property (nonatomic, strong) IBOutlet UIView *visibleToBtnContainer;
@property (nonatomic, strong) IBOutlet UIImageView *visibleToIcon;
@property (nonatomic, strong) IBOutlet UILabel *visibleToTextLabel;
@property (nonatomic, strong) IBOutlet HPGrowingTextView *postContentTextView;
@property (nonatomic, strong) IBOutlet UIScrollView *postAttachmentScrollView;
@property (nonatomic, strong) IBOutlet UIButton *cameraBtn;
@property (nonatomic, strong) IBOutlet UIButton *photosBtn;
@property (nonatomic, strong) IBOutlet UIButton *youtubeBtn;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *postContentTextViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *postAttachmentScrollViewHeight;

@end

@implementation CreatePostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Create a Post";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignTextView)];
    tap.cancelsTouchesInView = NO;
    [self.masterScrollView addGestureRecognizer:tap];
    
    self.visibleToBtnContainer.layer.masksToBounds = YES;
    self.visibleToBtnContainer.layer.cornerRadius = 3;
    
    self.postContentTextView.delegate = self;
    self.postContentTextView.placeholder = @"Write your post here.";
    self.postContentTextView.font = [UIFont fontWithName:@"Verdana" size:12.0];
    self.postContentTextView.minHeight = 150.0f;
    self.postContentTextView.maxHeight = MAXFLOAT;
    
    self.postAttachmentScrollViewHeight.constant = 0.0f;
    
    mediaPicker = [[UIImagePickerController alloc] init];
    mediaPicker.delegate = self;
    
    videos = [[NSMutableArray alloc] init];
    
    visibilitySettingsTitles = @[@"Public", @"My Colleagues", @"My Followers", @"Only Me"];
    visibilitySettingsIcons = @[@"group_icon", @"group_icon", @"group_icon", @"group_icon"];
    visibilitySettingsValues = @[@"public", @"my_colleague", @"my_follower", @"only_me"];
    
    if (!self.visibilitySettings) self.visibilitySettings = [[NSMutableArray alloc] init];
    if (!self.coursesRelations) self.coursesRelations = [[NSMutableArray alloc] init];
    if (!self.conexusRelations) self.conexusRelations = [[NSMutableArray alloc] init];
    [self updateVisibleToBtn];
    
    [self loadAssets];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(onCancelBtnClick:)];
    UIBarButtonItem *submitPostBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Publish", nil)
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(onSubmitPostBtnClick:)];
    [self.navigationItem setLeftBarButtonItem:cancelBtn animated:YES];
    [self.navigationItem setRightBarButtonItem:submitPostBtn animated:YES];
}

- (void)onCancelBtnClick:(id)sender
{
    BOOL ask = NO;
    if (currentOperation) ask = YES;
    else if ([attachedPhotos count] > 0 || [videos count] > 0 || ![[NSString trimWhiteSpace:self.postContentTextView.text] isEqualToString:@""])
        ask = YES;
    
    if (ask) {
        UIActionSheet *confirm = [[UIActionSheet alloc] initWithTitle:@"Discard this post?"
                                                     cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"]
                                                destructiveButtonItem:[RIButtonItem itemWithLabel:@"Discard" action:^{
                                                    [currentOperation cancel];
                                                    [self dismissViewControllerAnimated:YES completion:nil];
                                                }]
                                                     otherButtonItems:nil];
        [confirm showInView:self.view];
    } else {
        [currentOperation cancel];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)onSubmitPostBtnClick:(id)sender
{
    if ([[NSString trimWhiteSpace:self.postContentTextView.text] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Post text cannot be blank." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self resignTextView];
    uploadedImgsId = [[NSMutableArray alloc] initWithCapacity:attachedPhotos.count];
    currentUploadIndex = 0;
    if (currentOperation) [currentOperation cancel];
    currentOperation = nil;
    
    publishingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (attachedPhotos.count > 0 ) {
        [self uploadNextPhoto];
    } else {
        [self publishPost];
    }
}

- (void)uploadNextPhoto
{
    if (attachedPhotos.count > currentUploadIndex) {
        
        publishingHUD.labelText = [NSString stringWithFormat:@"Uploading photo %d of %lu", currentUploadIndex+1, (unsigned long)attachedPhotos.count];
        MWPhoto *photo = [attachedPhotos objectAtIndex:currentUploadIndex];
        
        [assetLibrary assetForURL:photo.photoURL
                      resultBlock:^(ALAsset *asset) {
                          
                          ALAssetRepresentation *rep = [asset defaultRepresentation];
                          
                          UIImage *image = [UIImage imageWithCGImage:[rep fullResolutionImage]
                                                               scale:[rep scale]
                                                         orientation:(UIImageOrientation)[rep orientation]];
                          NSData *imageData = [Tools imageDataWithRatio:image maxWidth:1024 maxHeight:1024];
                          
                          currentOperation = [BaseStore uploadPhoto:imageData block:^(NSDictionary *response, NSString *error) {
                              if (!error) {
                                  [uploadedImgsId addObject:[[response objectForKey:@"data"] objectForKey:@"id"]];
                                  if (currentUploadIndex == [attachedPhotos count]-1) {
                                      
                                      [self publishPost];
                                      
                                  } else {
                                      currentUploadIndex++;
                                      [self uploadNextPhoto];
                                  }
                              } else {
                                  [publishingHUD hide:YES];
                                  self.navigationItem.rightBarButtonItem.enabled = YES;
                              }
                          }];
                          
                      }
                     failureBlock:^(NSError *error){
                         [publishingHUD hide:YES];
                         self.navigationItem.rightBarButtonItem.enabled = YES;
                     }];
    } else {
        [publishingHUD hide:YES];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)publishPost
{
    publishingHUD.labelText = @"Publishing post...";
    
    NSMutableArray *courses = [[NSMutableArray alloc] init];
    NSMutableArray *conexus = [[NSMutableArray alloc] init];
    [self.coursesRelations enumerateObjectsUsingBlock:^(Course *courseObj, NSUInteger idx, BOOL *stop) {
        [courses addObject:courseObj.courseId];
    }];
    [self.conexusRelations enumerateObjectsUsingBlock:^(Conexus *conexusObj, NSUInteger idx, BOOL *stop) {
        [conexus addObject:conexusObj.conexusId];
    }];
    NSDictionary *relations = @{
                                @"course_ids": courses,
                                @"conexus_ids": conexus
                                };
    NSArray *visibilitySettings;
    if (self.coursesRelations.count > 0) visibilitySettings = @[@"course"];
    else if (self.conexusRelations.count > 0) visibilitySettings = @[@"conexus"];
    else visibilitySettings = [NSArray arrayWithArray:self.visibilitySettings];
    
    NSMutableArray *vids = [[NSMutableArray alloc] init];
    [videos enumerateObjectsUsingBlock:^(Video *video, NSUInteger idx, BOOL *stop) {
        [vids addObject:video.viewUrl];
    }];
    
    currentOperation = [PostStore createPost:self.postContentTextView.text withImages:uploadedImgsId withVideos:vids groupsIds:visibilitySettings relations:relations block:^(NSArray *postContent, NSString *error) {
        [publishingHUD hide:YES];
        currentOperation = nil;
        if (!error) {
            UINavigationController *nav = (UINavigationController*)[CNNavigationHelper shared].navigationController;
            UIViewController *controller = [nav topViewController];
            [TSMessage showNotificationInViewController:controller
                                                  title:@"Post published!"
                                               subtitle:nil
                                                   type:TSMessageNotificationTypeSuccess];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTF_REFRESH_HOME_FEED object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }];
}

- (IBAction)onVisibleToBtnClick:(id)sender
{
    VisibilitySettingsViewController *visibilitySettingsViewController = [[VisibilitySettingsViewController alloc] init];
    visibilitySettingsViewController.delegate = self;
    visibilitySettingsViewController.visibilitySettings = [self.visibilitySettings mutableCopy];
    visibilitySettingsViewController.coursesRelations = [self.coursesRelations mutableCopy];
    visibilitySettingsViewController.conexusRelations = [self.conexusRelations mutableCopy];
    BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:visibilitySettingsViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)onCameraBtnClick:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        mediaPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:mediaPicker animated:YES completion:nil];
    }
}

- (IBAction)onPhotosBtnClick:(id)sender
{
    photos = [[NSMutableArray alloc] init];
	thumbs = [[NSMutableArray alloc] init];
    
    @synchronized(assets) {
        NSMutableArray *copy = [assets copy];
        for (ALAsset *asset in copy) {
            [photos addObject:[MWPhoto photoWithURL:asset.defaultRepresentation.url]];
            [thumbs addObject:[MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]]];
        }
    }
    
    browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = NO;
    browser.displayNavArrows = NO;
    browser.displaySelectionButtons = YES;
    browser.alwaysShowControls = NO;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = NO;
    browser.startOnGrid = YES;
    browser.enableSwipeToDismiss = NO;
    [browser setCurrentPhotoIndex:0];
    
    previousSelections = [[NSMutableArray alloc] initWithArray:selections];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:browser];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)onYoutubeBtnClick:(id)sender
{
    YoutubeSearchViewController *youtubeSearchViewController = [[YoutubeSearchViewController alloc] init];
    youtubeSearchViewController.delegate = self;
    BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:youtubeSearchViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)displaySelectedAttachments
{
    attachedPhotos = [[NSMutableArray alloc] init];
    __block int nextX = 5;
    
    for (UIImageView *subview in [self.postAttachmentScrollView subviews]) {
        [subview removeFromSuperview];
    }
    
    [videos enumerateObjectsUsingBlock:^(Video *video, NSUInteger idx, BOOL *stop) {
        
        NSString *thumbnail = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/default.jpg", video.youtubeId];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(nextX, 0, POST_PICTURE_THUMBNAIL_SIZE, POST_PICTURE_THUMBNAIL_SIZE)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [imageView setImageWithURL:[NSURL URLWithString:thumbnail]
                  placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
        
        UIImageView *playBtn = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"post_video_play_btn"]];
        playBtn.center = imageView.center;
        
        [self.postAttachmentScrollView addSubview:imageView];
        [self.postAttachmentScrollView addSubview:playBtn];
        
        nextX = nextX + POST_PICTURE_THUMBNAIL_SIZE + POST_PICTURE_THUMBNAIL_SPACING;
    }];
    
    [selections enumerateObjectsUsingBlock:^(NSNumber *num, NSUInteger idx, BOOL *stop) {
        if (num.boolValue == YES) {
            MWPhoto *thumb = [thumbs objectAtIndex:idx];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:thumb.image];
            
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.frame = CGRectMake(nextX, 0, POST_PICTURE_THUMBNAIL_SIZE, POST_PICTURE_THUMBNAIL_SIZE);
            
            [self.postAttachmentScrollView addSubview:imageView];
            [attachedPhotos addObject:[photos objectAtIndex:idx]];
            
            nextX = nextX + POST_PICTURE_THUMBNAIL_SIZE + POST_PICTURE_THUMBNAIL_SPACING;
        }
    }];
    
    [self.postAttachmentScrollView setContentSize:CGSizeMake(nextX, POST_PICTURE_THUMBNAIL_SIZE)];
    self.postAttachmentScrollViewHeight.constant = (attachedPhotos.count > 0 || videos.count > 0) ? POST_PICTURE_THUMBNAIL_SIZE+5 : 0.0f;
}

- (void)resignTextView
{
    [self.postContentTextView resignFirstResponder];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    self.postContentTextViewHeight.constant = height;
}

- (void)updateVisibleToBtn
{
    if (self.visibilitySettings.count > 0) {
        [visibilitySettingsValues enumerateObjectsUsingBlock:^(NSString *value, NSUInteger idx, BOOL *stop) {
            if ([self.visibilitySettings containsObject:value]) {
                self.visibleToTextLabel.text = [visibilitySettingsTitles objectAtIndex:idx];
                self.visibleToIcon.contentMode = UIViewContentModeCenter;
                [self.visibleToIcon setImage:[UIImage imageNamed:[visibilitySettingsIcons objectAtIndex:idx]]];
                *stop = YES;
            }
        }];
    } else if (self.coursesRelations.count > 0) {
        Course *course = [self.coursesRelations objectAtIndex:0];
        self.visibleToTextLabel.text = [NSString stringWithFormat:@"%ld Course%s", (unsigned long)self.coursesRelations.count, self.coursesRelations.count > 1 ? "s" : ""];
        self.visibleToIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self.visibleToIcon setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", course.logoURL]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
        
    } else if (self.conexusRelations.count > 0) {
        Conexus *conexus = [self.conexusRelations objectAtIndex:0];
        self.visibleToTextLabel.text = [NSString stringWithFormat:@"%ld Conexus", (unsigned long)self.conexusRelations.count];
        self.visibleToIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self.visibleToIcon setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", conexus.logoURL]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
    }
}

#pragma mark - Load Assets

- (void)loadAssets {
    
    // Initialise
    assets = [NSMutableArray new];
    assetLibrary = [[ALAssetsLibrary alloc] init];
    selections = [NSMutableArray new];
    
    // Run in the background as it takes a while to get all assets from the library
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
        NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
        
        // Process assets
        void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result != nil) {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                    NSURL *url = result.defaultRepresentation.url;
                    [assetLibrary assetForURL:url
                                   resultBlock:^(ALAsset *asset) {
                                       if (asset) {
                                           @synchronized(assets) {
                                               [assets addObject:asset];
                                               [selections addObject:[NSNumber numberWithBool:NO]];
                                           }
                                       }
                                   }
                                  failureBlock:^(NSError *error){
                                      NSLog(@"operation was not successfull!");
                                  }];
                    
                }
            }
        };
        
        // Process groups
        void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
                [assetGroups addObject:group];
            }
        };
        
        // Process!
        [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                    usingBlock:assetGroupEnumerator
                                  failureBlock:^(NSError *error) {
                                      NSLog(@"There is an error");
                                  }];
        
    });
    
}

#pragma mark -
#pragma mark UIKeyboard Delegates

- (void)keyboardWillHide:(NSNotification *)notification
{
    float duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    keyboardFrame = CGRectZero;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(STATUS_BAR_HEIGHT+self.navigationController.navigationBar.height, 0.0, 0.0, 0.0);
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 16)
                     animations:^{
                         self.masterScrollView.contentInset = contentInsets;
                         self.masterScrollView.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)keyboardWillChange:(NSNotification *)notification
{
    float duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    keyboardFrame = [self.masterScrollView.superview convertRect:keyboardFrame fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(STATUS_BAR_HEIGHT+self.navigationController.navigationBar.height, 0.0, keyboardFrame.size.height, 0.0);
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 16)
                     animations:^{
                         self.masterScrollView.contentInset = contentInsets;
                         self.masterScrollView.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - VisibilitySettingsDelegate

- (void)onVisibilitySettingsUpdated:(NSMutableArray *)newVisibilitySettings courses:(NSMutableArray *)newCoursesRelations conexus:(NSMutableArray *)newConexusRelations
{
    self.visibilitySettings = newVisibilitySettings;
    self.coursesRelations = newCoursesRelations;
    self.conexusRelations = newConexusRelations;
    [self updateVisibleToBtn];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SearchYoutubeDelegate

- (void)didSelectYoutubeVideo:(Video *)video
{
    [videos addObject:video];
    [self displaySelectedAttachments];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [assetLibrary writeImageToSavedPhotosAlbum:image.CGImage
                                      metadata:[info objectForKey:UIImagePickerControllerMediaMetadata]
                               completionBlock:^(NSURL *assetURL, NSError *error) {
                                   ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *asset)
                                   {
                                       if (asset) {
                                           [assets insertObject:asset atIndex:0];
                                           [selections insertObject:[NSNumber numberWithBool:YES] atIndex:0];
                                           
                                           photos = [[NSMutableArray alloc] init];
                                           thumbs = [[NSMutableArray alloc] init];
                                           
                                           @synchronized(assets) {
                                               NSMutableArray *copy = [assets copy];
                                               for (ALAsset *asset in copy) {
                                                   [photos addObject:[MWPhoto photoWithURL:asset.defaultRepresentation.url]];
                                                   [thumbs addObject:[MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]]];
                                               }
                                           }
                                           [self displaySelectedAttachments];
                                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                       }
                                   };
                                   
                                   ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *error)
                                   {
                                       NSLog(@"Unable to find asset - %@", [error localizedDescription]);
                                   };
                                   
                                   [assetLibrary assetForURL:assetURL
                                                 resultBlock:resultblock
                                                failureBlock:failureblock];
                               }];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < photos.count)
        return [photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index
{
    if (index < thumbs.count)
        return [thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index
{
    //NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index
{
    if (index < selections.count)
        return [[selections objectAtIndex:index] boolValue];
    return NO;
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected
{
    [selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    //NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser canceled:(BOOL)canceled
{
    // If we subscribe to this method we must dismiss the view controller ourselves
    //NSLog(@"Did finish modal presentation");
    
    if (canceled) {
        selections = previousSelections;
    }
    [self displaySelectedAttachments];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
