//
//  UIViewController+JVideoPlayerAdd.m
//  JVideo
//
//  Created by you&me on 2019/12/11.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "UIViewController+JVideoPlayerAdd.h"
#import "UINavigationController+JVideoPlayerAdd.h"
#import <objc/message.h>
#import <WebKit/WKWebView.h>

@implementation UIViewController (JVideoPlayerAdd)

-(void)setJ_displayMode:(JPreViewDisplayMode)j_displayMode{
    objc_setAssociatedObject(self, @selector(j_displayMode), @(j_displayMode), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (j_displayMode == JPreViewDisplayMode_Origin) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}
-(JPreViewDisplayMode)j_displayMode{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}
-(UIGestureRecognizerState)j_fullscreenGestureState{
    return self.navigationController.j_fullscreenGestureState;
}

-(void)setJ_fadeArea:(NSArray<NSValue *> *)j_fadeArea{
    objc_setAssociatedObject(self, @selector(j_fadeArea), j_fadeArea, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(WKWebView *)j_considerWebView{
    return objc_getAssociatedObject(self, _cmd);
}
-(void)setJ_considerWebView:(WKWebView *)j_considerWebView{
    j_considerWebView.allowsBackForwardNavigationGestures = YES;
    objc_setAssociatedObject(self, @selector(j_considerWebView), j_considerWebView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<NSValue *> *)sj_fadeArea {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSj_fadeAreaViews:(NSArray<UIView *> *)sj_fadeAreaViews {
    objc_setAssociatedObject(self, @selector(sj_fadeAreaViews), sj_fadeAreaViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<UIView *> *)sj_fadeAreaViews {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSj_viewWillBeginDragging:(void (^)(__kindof UIViewController *))sj_viewWillBeginDragging {
    objc_setAssociatedObject(self, @selector(sj_viewWillBeginDragging), sj_viewWillBeginDragging, OBJC_ASSOCIATION_COPY);
}

- (void (^)(__kindof UIViewController *))sj_viewWillBeginDragging {
    return objc_getAssociatedObject(self, _cmd);
}


- (void)setSj_viewDidDrag:(void (^)(__kindof UIViewController *))sj_viewDidDrag {
    objc_setAssociatedObject(self, @selector(sj_viewDidDrag), sj_viewDidDrag, OBJC_ASSOCIATION_COPY);
}

- (void (^)(__kindof UIViewController *))sj_viewDidDrag {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSj_viewDidEndDragging:(void (^)(__kindof UIViewController *))sj_viewDidEndDragging {
    objc_setAssociatedObject(self, @selector(sj_viewDidEndDragging), sj_viewDidEndDragging, OBJC_ASSOCIATION_COPY);
}

- (void (^)(__kindof UIViewController *))sj_viewDidEndDragging {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSj_DisableGestures:(BOOL)sj_DisableGestures {
    objc_setAssociatedObject(self, @selector(sj_DisableGestures), @(sj_DisableGestures), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sj_DisableGestures {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end
