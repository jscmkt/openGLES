//
//  NSObject+JObserverHelper.h
//  JVideo
//
//  Created by you&me on 2019/11/25.
//  Copyright © 2019 you&me. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (JObserverHelper)
///添加观察者,无需移除(将会自动移除)
-(void)j_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

///添加观察者,无需移除(将会自动移除)
-(void)j_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void*)context;

@end

NS_ASSUME_NONNULL_END
