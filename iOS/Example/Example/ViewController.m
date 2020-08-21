//
//  ViewController.m
//  Example
//
//  Created by hang_pan on 2020/8/12.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"
#import "JSCoreViewController.h"

#import "AlertExecutor.h"
#import "TradeExecutor.h"
#import "Networking.h"
#import "NotifyExecutor.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height / 2)];
    [button1 addTarget:self action:@selector(openWebVC) forControlEvents:UIControlEventTouchUpInside];
    [button1 setTitle:@"WEB" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height / 2, self.view.bounds.size.width, self.view.bounds.size.height / 2)];
    [button2 addTarget:self action:@selector(openJSCoreVC) forControlEvents:UIControlEventTouchUpInside];
    [button2 setTitle:@"JSCORE" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.view addSubview:button1];
    [self.view addSubview:button2];
    
    [ExtJSBridge registExecutorClass:[AlertExecutor class]];
    [ExtJSBridge registExecutorClass:[TradeExecutor class]];
    [ExtJSBridge registExecutorClass:[Networking class]];
    [ExtJSBridge registExecutorClass:[NotifyExecutor class]];
}

- (void)openWebVC {
    WebViewController *vc = [WebViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openJSCoreVC {
    JSCoreViewController *vc = [JSCoreViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
