/*
 CTAssetsViewController.m
 
 The MIT License (MIT)
 
 Copyright (c) 2013 Clement CN Tsang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "CTAssetsPickerConstants.h"
//#import "CTAssetsPickerController.h"
#import "CTAssetsViewController.h"
#import "CTAssetsViewCell.h"
#import "CTAssetsSupplementaryView.h"
//#import "CTAssetsPageViewController.h"
//#import "CTAssetsViewControllerTransition.h"
#import "TCAssetManager.h"
#import "TCAssetCacheManager.h"
#import "TCImageViewController.h"
#import "TCAsset.h"

NSString * const CTAssetsPickerSelectedAssetsChangedNotification = @"CTAssetsPickerSelectedAssetsChangedNotification";


NSString * const CTAssetsViewCellIdentifier = @"CTAssetsViewCellIdentifier";
NSString * const CTAssetsSupplementaryViewIdentifier = @"CTAssetsSupplementaryViewIdentifier";
NSString * const TCAssetsSupplementaryHeaderIdentifier = @"TCAssetsSupplementaryHeaderIdentifier";


//@interface CTAssetsPickerController ()
//
//- (void)finishPickingAssets:(id)sender;
//
//- (NSString *)toolbarTitle;
//- (UIView *)noAssetsView;
//
//@end



@interface CTAssetsViewController ()

//@property (nonatomic, weak) CTAssetsPickerController *picker;
@property (nonatomic, strong) NSArray *assets;

@end





@implementation CTAssetsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
    self.title = @"图库";
    
    UICollectionViewFlowLayout *layout = [self collectionViewFlowLayoutOfOrientation:UIInterfaceOrientationPortrait];
    self.collectionView.collectionViewLayout = layout;
    
//    self.collectionView.allowsMultipleSelection = YES;
    
    [self.collectionView registerClass:CTAssetsViewCell.class
            forCellWithReuseIdentifier:CTAssetsViewCellIdentifier];
    
    [self.collectionView registerClass:TCAssetsSupplementaryHeader.class
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:TCAssetsSupplementaryHeaderIdentifier];
    
//    [self.collectionView registerClass:CTAssetsSupplementaryView.class
//            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
//                   withReuseIdentifier:CTAssetsSupplementaryViewIdentifier];
    
    self.preferredContentSize = kPopoverContentSize;
    
    
    [self addNotificationObserver];
    [self addGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:kTCAssetDidChangedNotification object:nil];
    
    TCAssetManager *assetManager = [TCAssetManager defaultManager];
    if (assetManager.status == TCAssetManagerStatus_Init) {
        [assetManager scanAssets];
    }
    else {
        [self reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupButtons];
    [self setupToolbar];
}

- (void)dealloc
{
    [self removeNotificationObserver];
}


#pragma mark - Accessors

//- (CTAssetsPickerController *)picker
//{
//    return (CTAssetsPickerController *)self.navigationController.parentViewController;
//}


#pragma mark - Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UICollectionViewFlowLayout *layout = [self collectionViewFlowLayoutOfOrientation:toInterfaceOrientation];
    [self.collectionView setCollectionViewLayout:layout animated:YES];
}


#pragma mark - Setup

- (void)setupViews
{
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)setupButtons
{
//    self.navigationItem.rightBarButtonItem =
//    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
//                                     style:UIBarButtonItemStyleDone
//                                    target:self.picker
//                                    action:@selector(finishPickingAssets:)];
//    
//    self.navigationItem.rightBarButtonItem.enabled = (self.picker.selectedAssets.count > 0);
}

- (void)setupToolbar
{
//    self.toolbarItems = self.picker.toolbarItems;
}

#pragma mark - Collection View Layout

- (UICollectionViewFlowLayout *)collectionViewFlowLayoutOfOrientation:(UIInterfaceOrientation)orientation
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize             = kThumbnailSize;
    layout.headerReferenceSize  = CGSizeMake(0, 47.0);
    
    if (UIInterfaceOrientationIsLandscape(orientation) && (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad))
    {
        layout.sectionInset            = UIEdgeInsetsMake(9.0, 2.0, 0, 2.0);
        layout.minimumInteritemSpacing = 3.0;
        layout.minimumLineSpacing      = 3.0;
    }
    else
    {
        layout.sectionInset            = UIEdgeInsetsMake(9.0, 0, 0, 0);
        layout.minimumInteritemSpacing = 2.0;
        layout.minimumLineSpacing      = 2.0;
    }
    
    return layout;
}


#pragma mark - Notifications

- (void)addNotificationObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(assetsLibraryChanged:)
                   name:ALAssetsLibraryChangedNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(selectedAssetsChanged:)
                   name:CTAssetsPickerSelectedAssetsChangedNotification
                 object:nil];
}

- (void)removeNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTAssetsPickerSelectedAssetsChangedNotification object:nil];
}


#pragma mark - Assets Library Changed

- (void)assetsLibraryChanged:(NSNotification *)notification
{
    // Reload all assets
    if (notification.userInfo == nil)
        [self performSelectorOnMainThread:@selector(reloadAssets) withObject:nil waitUntilDone:NO];
    
    // Reload effected assets groups
    if (notification.userInfo.count > 0)
        [self reloadAssetsGroupForUserInfo:notification.userInfo];
}


#pragma mark - Reload Assets Group

- (void)reloadAssetsGroupForUserInfo:(NSDictionary *)userInfo
{
    NSSet *URLs = [userInfo objectForKey:ALAssetLibraryUpdatedAssetGroupsKey];
    NSURL *URL  = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyURL];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@", URL];
    NSArray *matchedGroups = [URLs.allObjects filteredArrayUsingPredicate:predicate];
    
    // Reload assets if current assets group is updated
    if (matchedGroups.count > 0)
        [self performSelectorOnMainThread:@selector(reloadAssets) withObject:nil waitUntilDone:NO];
}



#pragma mark - Selected Assets Changed

- (void)selectedAssetsChanged:(NSNotification *)notification
{
//    NSArray *selectedAssets = (NSArray *)notification.object;
    
//    [[self.toolbarItems objectAtIndex:1] setTitle:[self.picker toolbarTitle]];
    
//    [self.navigationController setToolbarHidden:(selectedAssets.count == 0) animated:YES];
}



#pragma mark - Gesture Recognizer

- (void)addGestureRecognizer
{
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pushPageViewController:)];
    
    [self.collectionView addGestureRecognizer:longPress];
}


#pragma mark - Push Assets Page View Controller

- (void)pushPageViewController:(UILongPressGestureRecognizer *)longPress
{
//    if (longPress.state == UIGestureRecognizerStateBegan)
//    {
//        CGPoint point           = [longPress locationInView:self.collectionView];
//        NSIndexPath *indexPath  = [self.collectionView indexPathForItemAtPoint:point];
//
//        CTAssetsPageViewController *vc = [[CTAssetsPageViewController alloc] initWithAssets:self.assets];
//        vc.pageIndex = indexPath.item;
//
//        [self.navigationController pushViewController:vc animated:YES];
//    }
}



#pragma mark - Reload Assets

#pragma mark - Reload Data

- (void)reloadData
{
    TCAssetManager *assetManager = [TCAssetManager defaultManager];
    self.assets = assetManager.assetList;
    
    if (self.assets.count > 0 ||
        [TCAssetCacheManager defaultManager].assetList.count > 0)
    {
        [self.collectionView reloadData];
//        UICollectionView *v = (UICollectionView *)self.view;
//        NSLog(@"%f", v.contentSize.height);
        [self.collectionView setContentOffset:CGPointMake(0, self.collectionViewLayout.collectionViewContentSize.height)];
    }
    else
    {
        [self showNoAssets];
    }
}

#pragma mark - No assets

- (void)showNoAssets
{
//    self.collectionView.backgroundView = [self.picker noAssetsView];
    [self setAccessibilityFocus];
}

- (void)setAccessibilityFocus
{
    self.collectionView.isAccessibilityElement  = YES;
    self.collectionView.accessibilityLabel      = self.collectionView.backgroundView.accessibilityLabel;
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.collectionView);
}


#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.assets.count;
    }
    else if (section == 1) {
        return [TCAssetCacheManager defaultManager].assetList.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CTAssetsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                              CTAssetsViewCellIdentifier forIndexPath:indexPath];
    if (indexPath.section == 0) {
        ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
        [cell bind:asset];
    }
    else {
        TCAsset *asset = [[TCAssetCacheManager defaultManager].assetList objectAtIndex:indexPath.row];
        [cell bindLocalAsset:asset];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        CTAssetsSupplementaryView *view =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                           withReuseIdentifier:CTAssetsSupplementaryViewIdentifier
                                                  forIndexPath:indexPath];
        
        [view bind:self.assets];
        
        if (self.assets.count == 0)
            view.hidden = YES;
        
        return view;
    }
    else {
        TCAssetsSupplementaryHeader *view =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                           withReuseIdentifier:TCAssetsSupplementaryHeaderIdentifier
                                                  forIndexPath:indexPath];
        if (indexPath.section == 0) {
            view.label.text = @"相机胶卷";
        }
        else {
            view.label.text = @"未储存的照片";
        }
        return view;
    }
    return nil;
}


#pragma mark - Collection View Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
    CTAssetsViewCell *cell = (CTAssetsViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
//    if (!cell.isEnabled)
//        return NO;
//    else if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldSelectAsset:)])
//        return [self.picker.delegate assetsPickerController:self.picker shouldSelectAsset:asset];
//    else
        return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *image = nil;
    
    if (indexPath.section == 0) {
        if (indexPath.row >= self.assets.count) {
            return;
        }
        ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
        CGImageRef imageRef = asset.defaultRepresentation.fullScreenImage;
        image = [UIImage imageWithCGImage:imageRef];
       
    }
    else if (indexPath.section == 1) {
        NSArray *assetList = [TCAssetCacheManager defaultManager].assetList;
        if (indexPath.row >= assetList.count) {
            return;
        }
        
        TCAsset *asset = assetList[indexPath.row];
        image = asset.originalImage;
    }
    
    TCImageViewController *controller = [[TCImageViewController alloc] init];
    controller.image = image;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navController animated:YES completion:nil];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
//    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldDeselectAsset:)])
//        return [self.picker.delegate assetsPickerController:self.picker shouldDeselectAsset:asset];
//    else
        return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
//    [self.picker deselectAsset:asset];
//    
//    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didDeselectAsset:)])
//        [self.picker.delegate assetsPickerController:self.picker didDeselectAsset:asset];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
//    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
//    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldHighlightAsset:)])
//        return [self.picker.delegate assetsPickerController:self.picker shouldHighlightAsset:asset];
//    else
        return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
//    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
//    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didHighlightAsset:)])
//        [self.picker.delegate assetsPickerController:self.picker didHighlightAsset:asset];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
//    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didUnhighlightAsset:)])
//        [self.picker.delegate assetsPickerController:self.picker didUnhighlightAsset:asset];
}

- (IBAction)onBackAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end