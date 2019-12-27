//
//  UIViewController+JVideoPlayerAdd.h
//  JVideo
//
//  Created by you&me on 2019/12/11.
//  Copyright © 2019 you&me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "jScreenshotTransitionMode.h"
NS_ASSUME_NONNULL_BEGIN

@class WKWebView;

///返回时,前视图的显示模式
/// -快照:使用截图视图
/// -原点:使用原点视图。如果你使用它，我将把viewController的“edgesForExtendedLayout”改为“none”。
typedef NS_ENUM(NSUInteger,JPreViewDisplayMode) {
    JPreViewDisplayMode_Snapshot,//显示模式:使用截图(默认)
    JPreViewDisplayMode_Origin, //显示模式:原始视图
};

@interface UIViewController (JVideoPlayerAdd)
/**

 当手势触发时, 之前视图(将要返回的那个视图)的显示模式, 目前有两种: `SJPreViewDisplayMode_Origin` 使用原视图, `SJPreViewDisplayMode_Snapshot` 使用原视图的快照
 */
@property(nonatomic)JPreViewDisplayMode j_displayMode;

@property(nonatomic,readonly)UIGestureRecognizerState j_fullscreenGestureState;
/***
 考虑`webview`. 当设置此属性后,将会'启用返回上一个网页'.
 */
@property(nonatomic,weak)WKWebView *j_considerWebView;

/**
 指定区域不触发收拾 see 'sj_fadeAreaViews' method
 只有设置 手势类型为 `JFullscreenPopGestureType_Full` 的时候有用
 */

@property(nonatomic,strong)NSArray<NSValue *> *j_fadeArea;

/**
 指定区域不触发手势
 只有设置 手势类型为 `JFullscreenPopGestureType_Full` 的时候有用
 */
@property(nonatomic,strong)NSArray<UIView *> *j_fadeAreaViews;

///禁用全屏手势.默认是NO
@property(nonatomic,assign)BOOL j_DisableGrstures;

@property (nonatomic, copy, readwrite, nullable) void(^sj_viewWillBeginDragging)(__kindof UIViewController *vc);
@property (nonatomic, copy, readwrite, nullable) void(^sj_viewDidDrag)(__kindof UIViewController *vc);
@property (nonatomic, copy, readwrite, nullable) void(^sj_viewDidEndDragging)(__kindof UIViewController *vc);

@end

NS_ASSUME_NONNULL_END
