//
//  JSCoreViewController.m
//  Example
//
//  Created by hang_pan on 2020/8/20.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import "JSCoreViewController.h"
#import <ExtJSBridge/ExtJSBridgeHeader.h>

@interface JSCoreViewController()

@property (nonatomic, strong) JSContext *context;

@end

@implementation JSCoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [[JSContext alloc] init];
}

@end
