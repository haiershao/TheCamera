//
//  TCSettingViewController.m
//  TheCamera
//
//  Created by honey.vi on 14-10-4.
//  Copyright (c) 2014年 liunan. All rights reserved.
//

#import "TCSettingViewController.h"

@interface TCSettingViewController ()

@end

@implementation TCSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBackAct:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
