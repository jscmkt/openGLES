//
//  JSnapshotRecorder.m
//  JVideo
//
//  Created by you&me on 2019/12/11.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "JSnapshotRecorder.h"
#import <objc/message.h>
#import "UIViewController+JVideoPlayerAdd.h"

static const char *kJSnapshot = "kJSnapShot";
@interface JSnapshotRecorder : NSObject
@property(nonatomic,strong,readonly)UIView *rootView;
@property(nonatomic,strong,readonly,nullable)UIView *nav_bar_snapshotView;
@property(nonatomic,strong,readonly,nullable)UIView *tab_bar_snapshotView;
@property(nonatomic,strong,readonly,nullable)UIView *preSnapshotView;
@property(nonatomic,strong,readonly)UIView *preViewContainerView;
@property(nonatomic,strong,readonly)UIView *shadeView;
-(instancetype)initWithNavigationController:(__weak UINavigationController *__nullable)nav index:(NSInteger)index;
-(instancetype)init;

-(void)preparePopViewController;
-(void)endPopViewController;
@end
@interface JSnapshotRecorder (){
    __weak UINavigationController *_nav;
    NSInteger _index;
}
@end

@implementation JSnapshotRecorder
-(instancetype)init{
    return [self initWithNavigationController:nil index:0];
}

-(instancetype)initWithNavigationController:(UINavigationController *__weak)nav index:(NSInteger)index{
    if (self = [super init]) {
        _rootView = [UIView new];
        _rootView.frame = [UIScreen mainScreen].bounds;

        _preViewContainerView = [UIView new];
        _preViewContainerView.frame = _rootView.bounds;
        [_rootView addSubview:_preViewContainerView];

//        swi
    }
    return self;
}



@end


@interface JSnapshotServer ()
@property(nonatomic,readonly) CGFloat shift;
@end


@implementation JSnapshotServer

+(instancetype)shared{
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

-(instancetype)init{
    if (self = [super init]) {
        _shift = -[UIScreen mainScreen].bounds.size.width * 0.382;
    }
    return self;
}


#pragma mark - action
-(void)nav:(UINavigationController *)nav pushViewController:(UIViewController *)viewController{
    if (nav.childViewControllers.count == 0) return;
    NSInteger currentIndex = nav.childViewControllers.count - 1;
    UIViewController *currentVC = nav.childViewControllers[currentIndex];
    if ([nav isKindOfClass:[UIImagePickerController class]]) currentVC.j_displayMode = JPreViewDisplayMode_Snapshot;
    
}
@end
