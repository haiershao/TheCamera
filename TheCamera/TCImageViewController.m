//
//  TCImageViewController.m
//  TheCamera
//
//  Created by honey.vi on 14-10-12.
//  Copyright (c) 2014年 liunan. All rights reserved.
//

#import "TCImageViewController.h"

@interface TCImageViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL navbarHidden;

@end

@implementation TCImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNaviItems];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = 2.0f;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor blackColor];
    [self.scrollView addSubview:self.imageView];
    
    self.imageView.image = self.image;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAct:)];
    [self.scrollView addGestureRecognizer:tapGesture];
}

- (void)setupNaviItems
{
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelAct)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    UIView *rightItemsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, self.navigationController.navigationBar.bounds.size.height)];
    rightItemsView.backgroundColor = [UIColor clearColor];
    float offsetX = 0;
    static float btnWith = 30.0f;
    static float btnGap = 10.0f;
    
    if (self.canDelete) {
        rightItemsView.frame = CGRectMake(0, 0, 120, self.navigationController.navigationBar.bounds.size.height);
        UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [delBtn addTarget:self action:@selector(onDeleteAct) forControlEvents:UIControlEventTouchUpInside];
        [delBtn setTitle:@"Del" forState:UIControlStateNormal];
        delBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        delBtn.frame = CGRectMake(offsetX, 0, btnWith, rightItemsView.bounds.size.height);
        offsetX += (btnWith + btnGap);
        [rightItemsView addSubview:delBtn];
    }
    
    UIButton *clipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [clipBtn addTarget:self action:@selector(onClipAct) forControlEvents:UIControlEventTouchUpInside];
    [clipBtn setTitle:@"Clip" forState:UIControlStateNormal];
    clipBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    clipBtn.frame = CGRectMake(offsetX, 0, btnWith, rightItemsView.bounds.size.height);
    offsetX += (btnWith + btnGap);
    [rightItemsView addSubview:clipBtn];
    
    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoBtn addTarget:self action:@selector(onInfoAct) forControlEvents:UIControlEventTouchUpInside];
    infoBtn.frame = CGRectMake(offsetX, 0, btnWith, rightItemsView.bounds.size.height);
    infoBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    offsetX += (btnWith + btnGap);
    [rightItemsView addSubview:infoBtn];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn addTarget:self action:@selector(onSaveAct) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn setTitle:@"Save" forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    saveBtn.frame = CGRectMake(offsetX, 0, btnWith, rightItemsView.bounds.size.height);
    [rightItemsView addSubview:saveBtn];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightItemsView];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)dealloc
{
    self.scrollView.delegate = nil;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)onTapAct:(UITapGestureRecognizer *)sender
{
    [UIView animateWithDuration:0.3 animations:^(void) {
        if (self.navbarHidden) {
            self.navigationController.navigationBar.alpha = 1.0f;
        }
        else {
            self.navigationController.navigationBar.alpha = 0.0f;
        }
    } completion:^(BOOL finish) {
        if (self.navbarHidden) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }
        else {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }
        self.navbarHidden = !self.navbarHidden;
//        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return self.navbarHidden;
}

- (void)onCancelAct
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
}

- (void)onDeleteAct
{
    
}

- (void)onClipAct
{
    
}

- (void)onInfoAct
{
    
}

- (void)onSaveAct
{
    
}

@end
