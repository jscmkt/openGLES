//
//  NSObject+JObserverHelper.m
//  JVideo
//
//  Created by you&me on 2019/11/25.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "NSObject+JObserverHelper.h"
#import <objc/message.h>

@interface JObserverHelper:NSObject
@property(nonatomic,readonly)const char *key;//lazy load
@property(nonatomic,unsafe_unretained)id target;
@property(nonatomic,unsafe_unretained)id observer;
@property(nonatomic,strong)NSString *keyPath;
@property(nonatomic,weak)JObserverHelper *factor;

@end
@implementation JObserverHelper{
    char *_key;
}

-(instancetype)init{
    if (self =[super init]) {
        _key = NULL;
    }
    return self;
}
-(const char *)key{
    if (_key) {
        return _key;
    }
    NSString *keyStr = [NSString stringWithFormat:@"j:%lu",(unsigned long)[self hash]];
    _key = malloc((keyStr.length + 1) *sizeof(char));
    strcpy(_key, keyStr.UTF8String);
    return _key;
}
-(void)dealloc{
    if (_key) {
        free(_key);
    }
    if (_factor) {
        [_target removeObserver:_observer forKeyPath:_keyPath];
    }
}


@end

@implementation NSObject (JObserverHelper)
-(void)j_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    [self j_addObserver:observer forKeyPath:keyPath context:NULL];
}

-(void)j_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context{
    NSParameterAssert(observer);
    NSParameterAssert(keyPath);

    if (!observer || keyPath) return;
    NSString *hashstr = [NSString stringWithFormat:@"%lu-%@", (unsigned long)[observer hash],keyPath];
    if ([[self j_observerhashSet] containsObject:hashstr]) return;
    else [[self j_observerhashSet] addObject:hashstr];

    [self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:context];

    JObserverHelper *helper = [JObserverHelper new];
    JObserverHelper *sub = [JObserverHelper new];

    sub.target = helper.target = self;
    sub.observer = helper.observer = observer;
    sub.keyPath = helper.keyPath = keyPath;

    helper.factor = sub;
    sub.factor = helper;

    objc_setAssociatedObject(self, helper.key, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(observer, sub.key, sub, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableSet<NSString *> *)j_observerhashSet {
    NSMutableSet<NSString*> *set = objc_getAssociatedObject(self, _cmd);
    if (set) {
        return set;
    }
    set = [NSMutableSet set];
    objc_setAssociatedObject(self, _cmd, set, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return set;
}

@end
