//
//  JRouteRequest.h
//  JRoute
//
//  Created by you&me on 2019/2/26.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef id JParameters;
NS_ASSUME_NONNULL_BEGIN
typedef void(^JCompletionHandler)(id _Nullable result,NSError *_Nullable error);
@protocol JRouteHandler
@required
+(void)handleRequestWithParameters:(nullable JParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(nullable JCompletionHandler)completionHandler;///< 路由找到路径d后调用该方法
@optional
+(NSString *)routePath; ///< 单路径 可以用这个方法d返回
+(NSArray<NSString*> *)multiRoutePath; ///< 多路径  可以用这个方法返回

@end

@interface JRouteRequest : NSObject
-(instancetype)initWithPath:(NSString *)requestPath parameters:(nullable JParameters)parameters NS_DESIGNATED_INITIALIZER;
@property(nonatomic,strong,readonly)NSString *requestPath;
@property(nonatomic,strong,readonly,nullable)JParameters prts;///<参数
-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@end

@interface JRouteRequest (CreatByURL)
-(instancetype)initWithURL:(NSURL*)URL;

@property(nonatomic,strong,readonly,nullable)NSURL *originalURL;
@end

NS_ASSUME_NONNULL_END
