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
#import "TCCameraGridView.h"

@interface TCCameraViewController () <TCCameraHelperDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) TCCameraEngine *cameraEngine;
@property (weak, nonatomic) IBOutlet UIButton *shutterButton;
@property (weak, nonatomic) IBOutlet UIButton *flashModeBtn;

@property (weak, nonatomic) IBOutlet UIView *flashModeSwitchView;
@property (strong, nonatomic) UIView *coverView;
@property (strong, nonatomic) TCCameraGridView *gridView;

@end

@implementation TCCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.coverView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.coverView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
    [self.coverView addGestureRecognizer:tapGesture];
    
    self.flashModeSwitchView.hidden = YES;
    [self setButtonsEnabled:NO];
    
    self.cameraEngine = [TCCameraEngine sharedInstance];
    self.cameraEngine.delegate = self;
    self.cameraEngine.preview.frame = CGRectMake(-25, 0, self.view.bounds.size.width + 50, self.view.bounds.size.height);
    self.cameraEngine.preview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:self.cameraEngine.preview atIndex:0];
    [self setFlashMode:AVCaptureFlashModeAuto];
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

- (IBAction)onFlashModeBtnAct:(id)sender
{
    self.flashModeSwitchView.hidden = !self.flashModeSwitchView.hidden;
    if (!self.flashModeSwitchView.hidden) {
        [self.view addSubview:self.coverView];
        [self.view bringSubviewToFront:self.coverView];
        [self.view bringSubviewToFront:self.flashModeSwitchView];
    }
    else {
        [self.coverView removeFromSuperview];
    }
}

- (void)onTap
{
    [self onFlashModeBtnAct:nil];
}

- (IBAction)onFlashOff:(id)sender
{
    [self setFlashMode:AVCaptureFlashModeOff];
    self.flashModeSwitchView.hidden = YES;
}

- (IBAction)onFlashOn:(id)sender
{
    [self setFlashMode:AVCaptureFlashModeOn];
    self.flashModeSwitchView.hidden = YES;
}

- (IBAction)onFlashAuto:(id)sender
{
    [self setFlashMode:AVCaptureFlashModeAuto];
    self.flashModeSwitchView.hidden = YES;
}

- (void)setFlashMode:(AVCaptureFlashMode)model
{
    self.cameraEngine.currentFlashMode = model;
    NSString *btnTitle = nil;
    
    switch (model) {
        case AVCaptureFlashModeOn:
            btnTitle = @"On";
            break;
        case AVCaptureFlashModeOff:
            btnTitle = @"Off";
            break;
        default:
            btnTitle = @"Auto";
            break;
    }
    
    [self.flashModeBtn setTitle:btnTitle forState:UIControlStateNormal];
}

- (IBAction)onGridViewChange:(id)sender
{
    if (!self.gridView) {
        self.gridView = [[TCCameraGridView alloc] initWithFrame:self.view.bounds];
        [self.view insertSubview:self.gridView aboveSubview:self.cameraEngine.preview];
    }
    else {
        [self.gridView removeFromSuperview];
        self.gridView = nil;
    }
}

@end
