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
    self.view.backgroundColor = [UIColor whiteColor];
    self.context = [[JSContext alloc] init];
    [self.context ext_initializeBridge];
    self.context[@"say"] = ^{
        NSLog(@"say");
    };
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"js"];
    NSURL *url = [NSURL  fileURLWithPath:path];
    NSData *data =  [NSData dataWithContentsOfURL:url];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.context evaluateScript:string withSourceURL:url];
}

@end
