//
//  WebViewController.m
//  Example
//
//  Created by hang_pan on 2020/8/13.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import <ExtJSBridge/ExtJSBridgeHeader.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "GeneralBuilder.h"
#import "GeneralSecurity.h"
#import "AlertTest.h"

@interface WebViewController ()

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:[WKWebViewConfiguration new]];
    ExtJSBridge *bridge = [ExtJSBridge new];
    bridge.builder = [GeneralBuilder new];
    bridge.security = [GeneralSecurity new];
    [self.webView ext_connectToBridge:bridge];
    [self.view addSubview:self.webView];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]];
    [self.webView loadFileURL:url allowingReadAccessToURL:url];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"alert" style:UIBarButtonItemStylePlain target:self action:@selector(alert)]];
     
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotify:) name:@"NotifyFromJavascript" object:nil];
}

- (void)handleNotify:(NSNotification *)noti {
    self.title = [NSString stringWithFormat:@"%@", noti.object];
}

- (void)alert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Test Title" message:@"Lorem ipsum dolor sit amet, ligula suspendisse nulla pretium, rhoncus tempor fermentum, enim integer ad vestibulum volutpat." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
