//
//  TCCameraViewController.m
//  TheCamera
//
//  Created by honey.vi on 14-10-3.
//  Copyright (c) 2014年 liunan. All rights reserved.
//

#import "TCCameraViewController.h"
#import "TCCameraEngine.h"
#import "TCCameraPreview.h"
#import "TCSettingViewController.h"
#import "TCAssetCacheManager.h"

@interface TCCameraViewController () <TCCameraHelperDelegate>

@property (weak, nonatomic) IBOutlet UIButton *shutterButton;

@end

@implementation TCCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setButtonsEnabled:NO];
    
    TCCameraEngine *cameraEngine = [TCCameraEngine sharedInstance];
    cameraEngine.delegate = self;
    cameraEngine.preview.frame = CGRectMake(-25, 0, self.view.bounds.size.width + 50, self.view.bounds.size.height);
    cameraEngine.preview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:cameraEngine.preview atIndex:0];
    [cameraEngine setCurrentFlashMode:AVCaptureFlashModeOn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setButtonsEnabled:(BOOL)enabled
{
    self.shutterButton.enabled = enabled;
}

- (void)cameraEngineCapturingStillImage:(TCCameraEngine *)engine
{
    [[engine.preview layer] setOpacity:0.0];
    [UIView animateWithDuration:.25 animations:^{
        [[engine.preview layer] setOpacity:1.0];
    }];
}

- (void)cameraEngine:(TCCameraEngine *)engine sessionIsRunning:(BOOL)running
{
    [self setButtonsEnabled:running];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    [[TCCameraEngine sharedInstance] startRunning];
    [self setButtonsEnabled:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self setButtonsEnabled:NO];
    [super viewDidDisappear:animated];
    
    [[TCCameraEngine sharedInstance] stopRunning];
}

- (IBAction)onSwitchCamera:(id)sender
{
    [self setButtonsEnabled:NO];
    [[TCCameraEngine sharedInstance] changeCameraWithCompletion:^(void) {
        [self setButtonsEnabled:YES];
    }];
}

- (IBAction)capture:(id)sender
{
//    self.shutterButton.enabled = NO;
    [[TCCameraEngine sharedInstance] snapStillImage:^(NSData *imageData) {
//        self.shutterButton.enabled = YES;
        [[TCAssetCacheManager defaultManager] cacheImageData:imageData metaData:nil];
    }];
}

@end
