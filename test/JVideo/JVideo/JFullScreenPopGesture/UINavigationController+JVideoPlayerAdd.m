//
//  UINavigationController+JVideoPlayerAdd.m
//  JVideo
//
//  Created by you&me on 2019/12/12.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "UINavigationController+JVideoPlayerAdd.h"
#import <objc/message.h>
#import "UIViewController+JVideoPlayerAdd.h"
#import <WebKit/WebKit.h>
#import "JSnapshotRecorder.h"
// MARK:UINavigationController

@interface UINavigationController (JVideoPlayerAdd)
@property(nonatomic,strong,readonly)UIScreenEdgePanGestureRecognizer *J_edgePan;
@property(nonatomic,strong,readonly)UIPanGestureRecognizer *J_Pan;
@property(nonatomic)JFullscreenPopGestureType J_selectedType;


@end

@interface UINavigationController (JExtension)<UINavigationControllerDelegate>
@property(nonatomic)BOOL J_tookOver;
@end

@implementation UINavigationController (JExtension)

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class nav = [self class];
        SEL originalSelector = @selector(pushViewController:animated:);
//        SEL swizzledSelect = @s
    });
}

-(void)J_navSettings{
    self.J_tookOver = YES;
    self.interactivePopGestureRecognizer.enabled = NO;
    self.J_selectedType = self.J_selectedType; //need update

    //border shadow
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.view.layer.shadowOffset = CGSizeMake(0.5, 0);
    self.view.layer.shadowColor = [UIColor colorWithWhite:.2 alpha:1].CGColor;
    self.view.layer.shadowOpacity = 1;
    self.view.layer.shadowRadius = 2;
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    [CATransaction commit];
}

-(void)J_pushViewController:(UIViewController*)viewController animatied:(BOOL)animated {
    if(self.interactivePopGestureRecognizer && !self.self.J_tookOver) [self J_navSettings];
    [[JSnapshotServer shared] nav:self pushViewController:viewController];
    [self J_pushViewController:viewController animatied:animated];
}

- (void)setSJ_tookOver:(BOOL)SJ_tookOver {
    objc_setAssociatedObject(self, @selector(SJ_tookOver), @(SJ_tookOver), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)SJ_tookOver {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}


@end

// MARK: Gesture
@interface _JFullscreenGestureDelegate : NSObject<UIGestureRecognizerDelegate>
@property(nonatomic,weak,nullable) UINavigationController *navigationController;
@end

@implementation _JFullscreenGestureDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (self.navigationController.topViewController.j_DisableGrstures || [[self.navigationController valueForKey:@"_isTransition"] boolValue] || [self.navigationController.topViewController.j_considerWebView canGoBack]) return NO;
    else if(self.navigationController.childViewControllers.count <= 1) return NO;
    else if( [self.navigationController.childViewControllers.lastObject isKindOfClass:[UINavigationController class]]) return NO;
    return YES;
}
-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer{
    if (JFullscreenPopGestureType_EdgeLeft == self.navigationController.J_selectedType) return YES;
    if([self J_isFadeAreawithPoint:[gestureRecognizer locationInView:gestureRecognizer.view]]) return NO;
    CGPoint translate = [gestureRecognizer translationInView:self.navigationController.view];
    if (translate.x > 0 && 0 == translate.y) return YES;
    return NO;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if (UIGestureRecognizerStateFailed == gestureRecognizer.state || UIGestureRecognizerStateCancelled == gestureRecognizer.state) {
        return NO;
    }

    if(gestureRecognizer == [self.navigationController J_edgePan]){
        [self _jCancellGesture:gestureRecognizer];
        return YES;
    }
    if (([otherGestureRecognizer isMemberOfClass:NSClassFromString(@"UISCrollViewPanGestureRecognizer")] || [otherGestureRecognizer                                isMemberOfClass:NSClassFromString(@"UIScrollViewPagingSwipeGestureRecognizer")]) &&   [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        return [self J_considerScrollView:(UIScrollView *)otherGestureRecognizer.view gestureRecognizer:(UIPanGestureRecognizer*)gestureRecognizer otherGestureRecognizer:otherGestureRecognizer];
    }

    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (![otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"_MKMapContentView")]) {
            return NO;
        }

        //consider `MKMapContentView`

        if ((self.navigationController.topViewController.j_fadeArea || self.navigationController.topViewController.j_fadeAreaViews)) {
            [self _jCancellGesture:otherGestureRecognizer];
            return YES;
        }

        //map view default fade area
        CGRect rect = (CGRect){CGPointMake(50, 0),self.navigationController.view.frame.size};
        if (![self rect:rect containerPoint:point]) {
            [self _jCancellGesture:otherGestureRecognizer];
            return  YES;
        }
        return NO;
    }

    if ( (self.navigationController.topViewController.j_fadeArea || self.navigationController.topViewController.j_fadeAreaViews)
        && ![self J_isFadeAreawithPoint:point] ) {
        [self _jCancellGesture:otherGestureRecognizer];
        return YES;
    }
    return NO;

}

-(BOOL)J_isFadeAreawithPoint:(CGPoint)point{
    __block BOOL isFadeArea = NO;
    if (0 != self.navigationController.topViewController.j_fadeArea.count) {
        [self.navigationController.topViewController.j_fadeArea enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![self rect:[obj CGRectValue] containerPoint:point]) {
                return;
            }
            isFadeArea = YES;
            *stop = YES;
        }];

    }

    if (!isFadeArea && 0 != self.navigationController.topViewController.j_fadeAreaViews.count) {
        [self.navigationController.topViewController.j_fadeAreaViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( ![self rect:obj.frame containerPoint:point] ) return;
            isFadeArea = YES;
            *stop = YES;
        }];
    }

    return isFadeArea;
}

-(BOOL)rect:(CGRect)rect containerPoint:(CGPoint)point{
    if (!self.navigationController.isNavigationBarHidden) {
        rect = [self.navigationController.view convertRect:rect toView:self.navigationController.topViewController.view];
    }
    return CGRectContainsPoint(rect, point);
}
-(BOOL)J_considerScrollView:(UIScrollView *)scrollView gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer otherGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([scrollView isKindOfClass:NSClassFromString(@"_UIQueuingScrollView")]) {
        return [self J_considerQueuingScrollView:scrollView gestureRecognizer:gestureRecognizer otherGestureRecognizer:otherGestureRecognizer];
    }

    CGPoint translate = [gestureRecognizer translationInView:self.navigationController.view];
    if(0 == scrollView.contentOffset.x + scrollView.contentInset.left && !scrollView.decelerating && translate.x > 0 && 0 == translate.y){
        [self _jCancellGesture:otherGestureRecognizer];
        return YES;
    }
    return NO;
}
-(BOOL)J_considerQueuingScrollView:(UIScrollView *)scrollView gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer otherGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    UIPageViewController *pageVC = [self J_findingPageViewControllerWithQueueingScrollView:scrollView];

    id<UIPageViewControllerDataSource> dataSource = pageVC.dataSource;
    UIViewController *beforeViewController = nil;
    if (0 != pageVC.viewControllers.count) {
        beforeViewController = [dataSource pageViewController:pageVC viewControllerBeforeViewController:pageVC.viewControllers.firstObject];
    }

    if (beforeViewController || scrollView.decelerating) {
        return NO;
    }else{
        [self _jCancellGesture:otherGestureRecognizer];
        return YES;
    }
}
-(UIPageViewController *)J_findingPageViewControllerWithQueueingScrollView:(UIScrollView *)scrollView{
    UIResponder *responder = scrollView.nextResponder;
    while (![responder isKindOfClass:[UIPageViewController class]]) {
        responder = responder.nextResponder;
        if ([responder isMemberOfClass:[UIResponder class]] || !responder) {
            responder = nil;
            break;
        }
    }
    return (UIPageViewController *)responder;
}

-(void)_jCancellGesture:(UIGestureRecognizer *)gesture{
    [gesture setValue:@(UIGestureRecognizerStateCancelled) forKey:@"state"];
}
@end
@implementation UINavigationController (JVideoPlayerAdd)

static const char *k_JFullscreenGestureDelegate = "_JFullscreenGestureDelegate";
-(_JFullscreenGestureDelegate*)_jFullscreenGestureDelegate {
    _JFullscreenGestureDelegate *delegate = objc_getAssociatedObject(self, k_JFullscreenGestureDelegate);
    if (!delegate) {
        delegate = _JFullscreenGestureDelegate.new;
        objc_setAssociatedObject(self, k_JFullscreenGestureDelegate, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}

- (UIPanGestureRecognizer *)J_Pan{
    UIPanGestureRecognizer *J_pan = objc_getAssociatedObject(self, _cmd);
    if (J_pan) {
        return J_pan;
    }
    J_pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(<#selector#>)];

    return J_pan;
}

-(void)J_handlePanGR:(UIPanGestureRecognizer *)pan{
    CGFloat offset = [pan translationInView:self.view].x;
    switch (pan.state) {
        case UIGestureRecognizerStatePossible: break;
        case UIGestureRecognizerStateBegan:
            <#statements#>
            break;

        default:
            break;
    }
}

-(void)J_ViewWillBeginDragging:(CGFloat)offset{
    //resign keybord
    [self.view endEditing:YES];
    [[JSnapshotServer shared] nav:self preparePopViewController:self.childViewControllers.lastObject];
    if (self.topViewController.sj_viewWillBeginDragging) {
        self.topViewController.sj_viewWillBeginDragging(self.topViewController);
    }
//    self
}
-(void)J_ViewDidDrag:(CGFloat)offset{
    if (offset < 0) {
        offset = 0;
    }
    self.view.transform = CGAffineTransformMakeTranslation(offset, 0);
    [[JSnapshotServer shared]nav:self preparePopViewController:self.childViewControllers.lastObject];
    if(self.topViewController.sj_viewDidDrag){
        self.topViewController.sj_viewDidDrag(self.topViewController);
    }
}
-(void)
@end
