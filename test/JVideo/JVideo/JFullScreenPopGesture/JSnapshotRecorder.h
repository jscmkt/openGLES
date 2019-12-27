//
//  JSnapshotRecorder.h
//  JVideo
//
//  Created by you&me on 2019/12/11.
//  Copyright © 2019 you&me. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "jScreenshotTransitionMode.h"
NS_ASSUME_NONNULL_BEGIN

@interface JSnapshotServer : NSObject

@property(nonatomic)JScreenshotTransitionMode transitionMode;

+(instancetype)shared;

#pragma mark - action
-(void)nav:(UINavigationController *)nav pushViewController:(UIViewController*)viewController;

#pragma mark -
-(void)nav:(UINavigationController *)nav preparePopViewController:(UIViewController*)viewController;
- (void)nav:(UINavigationController *)nav poppingViewController:(UIViewController *)viewController offset:(double)offset;
- (void)nav:(UINavigationController *)nav willEndPopViewController:(UIViewController *)viewController pop:(BOOL)pop;
- (void)nav:(UINavigationController *)nav endPopViewController:(UIViewController *)viewController;
@end

NS_ASSUME_NONNULL_END
