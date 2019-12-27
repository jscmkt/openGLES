//
//  JRoute.h
//  JRoute
//
//  Created by you&me on 2019/2/26.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRouteRequest.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^JRouterUnhandledCallback)(JRouteRequest *request,UIViewController *topViewController);///<无法处理时的回调
@interface JRoute : NSObject
+(instancetype)shared;
-(void)handleRequest:(JRouteRequest*)request completionHandler:(nullable JCompletionHandler)completionHandler;
@property(nonatomic,copy,nullable)JRouterUnhandledCallback unhandledCallBack; /// < 协议方法
-(BOOL)canHandleRoutePath:(NSString *)routePath;/// < 是否可以处理某个路径
@end

NS_ASSUME_NONNULL_END
