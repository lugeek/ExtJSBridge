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
#import "GeneralSecurity.h"

@interface WebViewController ()<WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:[WKWebViewConfiguration new]];
    [self.webView ext_initializeBridgeWithName:@"ext"];
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


- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    completionHandler(@"abc");
    
}
@end
