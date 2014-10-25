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

@property (weak, nonatomic) IBOutlet UIView *shutterView;
@property (weak, nonatomic) IBOutlet UIView *ISOView;
@property (weak, nonatomic) IBOutlet UILabel *shutterLabel;
@property (weak, nonatomic) IBOutlet UILabel *ISOLabel;

@property (weak, nonatomic) IBOutlet UIView *seniorControlBar;
@property (assign, nonatomic) BOOL isControlBarHidden;
@property (weak, nonatomic) IBOutlet UIButton *controlBarHiddenBtn;

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
    
    self.isControlBarHidden = YES;
    
    self.cameraEngine.whiteBalanceTemp = 4000;
    self.cameraEngine.whiteBalanceMode = AVCaptureWhiteBalanceModeLocked;
    
    self.ISOView.hidden = YES;
    self.shutterView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    [[TCCameraEngine sharedInstance] startRunning];
    [self setButtonsEnabled:YES];
    [self setControlBarHidden:self.isControlBarHidden animation:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self setButtonsEnabled:NO];
    [super viewDidDisappear:animated];
    
    [[TCCameraEngine sharedInstance] stopRunning];
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
    [self setCoverViewHidden:!self.flashModeSwitchView.hidden];
    [self setFlashSwitchViewHidden:!self.flashModeSwitchView.hidden];
}

- (void)setFlashSwitchViewHidden:(BOOL)hidden
{
    self.flashModeSwitchView.hidden = hidden;
    [self setCoverViewHidden:hidden];
    if (!hidden) {
        [self.view bringSubviewToFront:self.flashModeSwitchView];
    }
}

- (void)setCoverViewHidden:(BOOL)hidden
{
    if (hidden) {
        [self.coverView removeFromSuperview];
    }
    else {
        [self.view addSubview:self.coverView];
        [self.view bringSubviewToFront:self.coverView];
    }
}

- (void)onTap
{
    [self setFlashSwitchViewHidden:YES];
    [self setCoverViewHidden:YES];
}

- (IBAction)onFlashOff:(id)sender
{
    [self setFlashMode:AVCaptureFlashModeOff];
    [self setFlashSwitchViewHidden:YES];
}

- (IBAction)onFlashOn:(id)sender
{
    [self setFlashMode:AVCaptureFlashModeOn];
    [self setFlashSwitchViewHidden:YES];
}

- (IBAction)onFlashAuto:(id)sender
{
    [self setFlashMode:AVCaptureFlashModeAuto];
    [self setFlashSwitchViewHidden:YES];
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

- (IBAction)onControlBarHiddenAct:(id)sender
{
    self.isControlBarHidden = !self.isControlBarHidden;
    [self setControlBarHidden:self.isControlBarHidden animation:YES];
}

- (void)setControlBarHidden:(BOOL)hidden animation:(BOOL)animation
{
    CGRect frame = self.seniorControlBar.frame;
    if (hidden) {
        frame.origin.x = self.view.bounds.size.width;
    }
    else {
        frame.origin.x = 0;
    }
    
    if (!animation) {
        self.seniorControlBar.frame = frame;
    }
    else {
        [UIView animateWithDuration:0.2f animations:^(void) {
            self.seniorControlBar.frame = frame;
        }];
    }
    self.isControlBarHidden = hidden;
}

#pragma  mark - ISO

- (void)setISOViewHidden:(BOOL)hidden
{
    self.ISOView.hidden = hidden;
}


- (IBAction)onISOAct:(id)sender
{
    [self setISOViewHidden:!self.ISOView.hidden];
}

- (IBAction)onISOSelected:(id)sender
{
    //    [self setISOViewHidden:YES];
    UIButton *btn = sender;
    self.ISOLabel.text = [NSString stringWithFormat:@"%d", btn.tag];
    [self setCurrentISOValue:btn.tag];
    self.ISOLabel.textColor = [UIColor blueColor];
}

- (void)setCurrentISOValue:(NSInteger)ISOValue
{
    NSLog(@"setCurrentISOValue: %d", ISOValue);
}

- (NSInteger)currentISOValue
{
    return 0;
}

#pragma mark - shutter

- (void)setShutterViewHidden:(BOOL)hidden
{
    self.shutterView.hidden = hidden;
}

- (IBAction)onShutterSpeedAct:(id)sender
{
    [self setShutterViewHidden:!self.shutterView.hidden];
}

- (IBAction)onShutterSpeedSelected:(id)sender
{
//    [self setShutterViewHidden:YES];
    float shutterSpeed = 0;
    UIButton *btn = sender;
    if (btn.tag == 1 || btn.tag == 0) {
        shutterSpeed = 1.0f;
        self.shutterLabel.text = @"1";
    }
    else {
        shutterSpeed = (1.0f / btn.tag);
        self.shutterLabel.text = [NSString stringWithFormat:@"1/%d", btn.tag];
    }
    
    [self setCurrentShutterSpeed:shutterSpeed];
    self.shutterLabel.textColor = [UIColor blueColor];
}

- (void)setCurrentShutterSpeed:(float)shutterSpeed
{
    NSLog(@"setCurrentShutterSpeed:%f", shutterSpeed);
}

- (float)currentShutterSpeed
{
    return 0;
}

- (IBAction)onSetShutterAndISOAutoAct:(id)sender
{
    self.shutterLabel.textColor = [UIColor grayColor];
    self.ISOLabel.textColor = [UIColor grayColor];
    [self setShutterViewHidden:YES];
    [self setISOViewHidden:YES];
}

@end
