//
//  ExtJSExecutorProtocol.h
//  Pods
//
//  Created by Pn-X on 2020/8/15.
//

#ifndef ExtJSExecutorProtocol_h
#define ExtJSExecutorProtocol_h

#import "ExtJSMessage.h"

@protocol ExtJSExecutorProtocol <NSObject>

- (void)ext_handleJSMessage:(ExtJSMessage *)message;

@end

#endif /* ExtJSExecutorProtocol_h */
