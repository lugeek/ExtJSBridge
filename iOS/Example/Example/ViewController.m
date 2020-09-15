//
//  ViewController.m
//  Example
//
//  Created by Pn-X on 2020/8/23.
//  Copyright © 2020 pn-x. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"
#import "JSCoreViewController.h"
#import <ExtJSBridge/ExtJSModuleFactory.h>
#import "EnvModule.h"
#import "NavigatorModule.h"
#import "TimerModule.h"
#import "AlertModule.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ExtJSBridge";
    
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
    
    [[ExtJSModuleFactory singleton] registerModuleClass:[EnvModule class]];
    [[ExtJSModuleFactory singleton] registerModuleClass:[NavigatorModule class]];
    [[ExtJSModuleFactory singleton] registerModuleClass:[TimerModule class]];
    [[ExtJSModuleFactory singleton] registerModuleClass:[AlertModule class]];
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
