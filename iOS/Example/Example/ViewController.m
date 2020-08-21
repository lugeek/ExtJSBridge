//
//  ViewController.m
//  Example
//
//  Created by hang_pan on 2020/8/12.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"
#import "AlertExecutor.h"
#import "TradeExecutor.h"
#import "Networking.h"
#import "NotifyExecutor.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openWebVC)]];
    
    [ExtJSBridge registExecutorClass:[AlertExecutor class]];
    [ExtJSBridge registExecutorClass:[TradeExecutor class]];
    [ExtJSBridge registExecutorClass:[Networking class]];
    [ExtJSBridge registExecutorClass:[NotifyExecutor class]];
    
}

- (void)openWebVC {
    WebViewController *vc = [WebViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
