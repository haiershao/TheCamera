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
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelAct)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
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

@end
