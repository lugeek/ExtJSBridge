//
//  ExtJSBridge.h
//  Pods-Example
//
//  Created by hang_pan on 2020/8/12.
//

#import <Foundation/Foundation.h>
#import "ExtJSSecurity.h"
#import "ExtJSExecutorBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExtJSBridge : NSObject<WKScriptMessageHandler>

//default ext
@property (nonatomic, strong, readonly) NSString *name;

//verify the message form webview to protect data
@property (nonatomic, strong) ExtJSSecurity *security;

//build a executor to handle message
@property (nonatomic, strong) ExtJSExecutorBuilder *builder;

- (instancetype)initWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
