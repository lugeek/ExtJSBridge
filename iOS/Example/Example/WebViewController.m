//
//  WebViewController.m
//  Example
//
//  Created by hang_pan on 2020/8/13.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import "WebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <ExtJSBridge/WKWebView+ExtJSBridge.h>
#import <ExtJSBridge/ExtJSModule.h>
#import "NavigatorModule.h"

@interface WebViewController ()<WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:[WKWebViewConfiguration new]];
    self.view.backgroundColor = [UIColor whiteColor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.webView ext_initializeBridge];
        [self.view addSubview:self.webView];
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]];
        [self.webView loadFileURL:url allowingReadAccessToURL:url];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NavigatorModule *module = (NavigatorModule *)[self.webView.ext_bridge moduleInstanceWithName:@"navigator"];
    [module handleViewDidAppear];
}

@end
