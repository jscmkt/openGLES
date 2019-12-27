//
//  JToast.h
//  PlayerDemo
//
//  Created by you&me on 2019/1/30.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
typedef enum jToastGravity{
    jToastGravityTop = 10000001,
    jToastGravityBottom,
    jToastGravityCenter
}jToastGravity;
typedef enum JToastDuration{
    JToastDurationLong = 10000,
    JToastDurationShort = 1000,
    JToastDurationNormal = 3000
}JToastDuration;
typedef enum JToastType{
    JToastTypeInfo = -100000,
    JToastTypeNotice,
    JToastTypeWarning,
    JToastTypeError,
    JToastTypeNone
}JToastType;
typedef enum{
    JToastImageLocationTop,
    JToastImageLocationLeft
} JToastImageLocation;
@class JToastSetting;
@interface JToast : NSObject
@property(nonatomic)JToastSetting *settings;
@property(nonatomic)NSTimer *timer;
@property(nonatomic)UIView *view;
@property(nonatomic,copy)NSString *text;
+(void)showText:(NSString*)text;
-(void)show;
-(void)show:(JToastType)type;
-(JToast*)setDuration:(NSInteger)duration;
-(JToast*)setGravity:(jToastGravity)gravity
           ofSetLeft:(NSInteger)left
            ofSetTop:(NSInteger)top;
-(JToast*)setGravity:(jToastGravity)gravity;
-(JToast*)setPosition:(CGPoint)position;
-(JToast*)setFonSize:(CGFloat)fonSize;
-(JToast*)setUseShadow:(BOOL)useShadow;
-(JToast*)setCornerRadius:(CGFloat)cornerRadius;
-(JToast*)setBgRed:(CGFloat)bgRed;
-(JToast*) setBgGreen:(CGFloat) bgGreen;
-(JToast*) setBgBlue:(CGFloat) bgBlue;
-(JToast*) setBgAlpha:(CGFloat) bgAlpha;

+(JToast*)makeText:(NSString*)text;

-(JToastSetting*)theSettings;

@end


@interface JToastSetting : NSObject
@property(nonatomic,assign)NSInteger duration;
@property(nonatomic,assign)jToastGravity gravity;
@property(nonatomic,assign)CGPoint position;
@property(nonatomic,assign)CGFloat fontSize;
@property(nonatomic,assign)BOOL useShadow;
@property(nonatomic,assign)CGFloat cornerRadius;
@property(nonatomic,assign)CGFloat bgRed;
@property(nonatomic,assign) CGFloat bgGreen;
@property(nonatomic,assign) CGFloat bgBlue;
@property(nonatomic,assign) CGFloat bgAlpha;
@property(nonatomic,assign) NSInteger offsetLeft;
@property(nonatomic,assign) NSInteger offsetTop;
@property(nonatomic,readonly) NSDictionary *images;
@property(nonatomic,assign)JToastImageLocation imageLocation;


-(void)setImage:(UIImage*)img forType:(JToastType)type;
-(void)setImage:(UIImage*)img withLocation:(JToastImageLocation)location forType:(JToastType)type;
+(JToastSetting*)getSharedSettings;
@end


NS_ASSUME_NONNULL_END
