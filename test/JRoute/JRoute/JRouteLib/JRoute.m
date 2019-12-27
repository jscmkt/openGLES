//
//  JRoute.m
//  JRoute
//
//  Created by you&me on 2019/2/26.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import "JRoute.h"
#import <objc/message.h>
static UIViewController *_sj_get_top_view_controller(){
    UIViewController *vc = UIApplication.sharedApplication.keyWindow.rootViewController;
    while ([vc isKindOfClass:[UINavigationController class]] || [vc isKindOfClass:[UITabBarController class]]) {
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController *)vc topViewController];
        }
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = [(UITabBarController*)vc selectedViewController];
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }

    }
    return vc;
}
@interface JRoute ()
@property(nonatomic,strong,readonly)NSMutableDictionary<NSString*,Class<JRouteHandler>> *handlersM;///< 储存路径参数
@end
@implementation JRoute
+(instancetype)shared{
    static id _instace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    return _instace;
}

-(instancetype)init{
    if (self = [super init]) {
        _handlersM = [NSMutableDictionary new];

        unsigned int img_count = 0;
        const char ** imgs = objc_copyImageNames(&img_count);
        const char *main = NSBundle.mainBundle.bundlePath.UTF8String;
        for (unsigned int i=0; i<img_count; ++i) {
            const char *img = imgs[i];
            if (!strstr(img, main)) continue;
            unsigned int cls_count = 0;
            const char **classes = objc_copyClassNamesForImage(img, &cls_count);
            Protocol *p_handler = @protocol(JRouteHandler);
            for (unsigned int j=0; j<cls_count; ++j) {
                const char *cls_name = classes[j];
                NSString *cls_str = [NSString stringWithUTF8String:cls_name];
                Class cls = NSClassFromString(cls_str);
                if (![cls conformsToProtocol:p_handler]) {
                    continue;
                }
                if (![(id)cls respondsToSelector:@selector(handleRequestWithParameters:topViewController:completionHandler:)]) {
                    continue;
                }
                if ([(id)cls respondsToSelector:@selector(routePath)]) {
                    _handlersM[[(id<JRouteHandler>)cls routePath]] = cls;
                }else if ([(id)cls respondsToSelector:@selector(multiRoutePath)]){
                    for (NSString *rp in [(id<JRouteHandler>)cls multiRoutePath]) {
                        _handlersM[rp] = cls;
                    }
                }
            }
            if (classes) {
                free(classes);
            }
        }
        if (imgs) {
            free(imgs);
        }
    }
    return self;

}

-(void)handleRequest:(JRouteRequest *)request completionHandler:(JCompletionHandler)completionHandler{
    NSParameterAssert(request);
    if (!request) return;
    Class<JRouteHandler> handler = _handlersM[request.requestPath];
    if (handler) {
        [handler handleRequestWithParameters:request.prts topViewController:_sj_get_top_view_controller() completionHandler:completionHandler];
    }
    else {
        printf("\n (-_-) Unhandled request:%s",request.description.UTF8String);
        if (_unhandledCallBack) {
            _unhandledCallBack(request,_sj_get_top_view_controller());
        }
    }
}
-(BOOL)canHandleRoutePath:(NSString *)routePath{
    if (0 == routePath.length) {
        return NO;
    }
    return _handlersM[routePath];
}
@end
