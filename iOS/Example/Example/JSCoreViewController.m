//
//  JSCoreViewController.m
//  Example
//
//  Created by hang_pan on 2020/8/20.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import "JSCoreViewController.h"
#import <ExtJSBridge/JSContext+ExtJSBridge.h>

@interface JSCoreViewController()

@property (nonatomic, strong) JSContext *context;

@end

@implementation JSCoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        JSVirtualMachine *vm = [JSVirtualMachine new];
        self.context = [[JSContext alloc] initWithVirtualMachine:vm];
        [self.context ext_initializeBridge];
        [self loadRuntime];
        [self loadJSCode];
    });
}

- (void)loadRuntime {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"context-runtime.min" ofType:@"js"]];
    NSData *data =  [NSData dataWithContentsOfURL:url];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.context evaluateScript:string withSourceURL:url];
}

- (void)loadJSCode {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"js"]];
    NSData *data =  [NSData dataWithContentsOfURL:url];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.context evaluateScript:string withSourceURL:url];
}

@end
