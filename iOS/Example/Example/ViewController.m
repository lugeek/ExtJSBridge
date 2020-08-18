//
//  ViewController.m
//  Example
//
//  Created by hang_pan on 2020/8/12.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openWebVC)]];
}

- (void)openWebVC {
    WebViewController *vc = [WebViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
