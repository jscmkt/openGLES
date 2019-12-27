//
//  JToast.m
//  PlayerDemo
//
//  Created by you&me on 2019/1/30.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import "JToast.h"


#define CURRENT_TOAST_TAG 1258022
static const CGFloat kCompomentPadding = 16;
@interface JToast (private)
-(JToast*)setting;
-(CGRect)_toastFrameForImageSize:(CGSize)imageSize withLocation:(JToastImageLocation)location andTextSize:(CGSize)textSize;
-(CGRect)_frameForImageWithType:(JToastType)type inToastFrame:(CGRect)toastFrame;
@end
@implementation JToast

-(id)initWithText:(NSString*)text{
    if (self = [super init]) {
        self.text = text;
    }
    return self;
}
-(void)show:(JToastType)type{
    JToastSetting *theSettings = self.settings;
    if (!theSettings) {
        theSettings = [JToastSetting getSharedSettings];
    }
    UIImage *image = [theSettings.images valueForKey:[NSString stringWithFormat:@"%i",type]];

    UIFont *font = [UIFont systemFontOfSize:theSettings.fontSize];
    CGSize textSize = [self.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width* 200/375 - 32, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:theSettings.fontSize]} context:nil].size;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 200/357 - 32, textSize.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = font;
    label.text = self.text;
    label.numberOfLines = 0;
    if (theSettings.useShadow) {
        label.shadowColor = [UIColor darkGrayColor];
        label.shadowOffset = CGSizeMake(1, 1);
    }

    UIButton *v = [UIButton buttonWithType:UIButtonTypeCustom];
    if (image) {
        v.frame = [self _toastFrameForImageSize:image.size withLocation:[theSettings imageLocation] andTextSize:textSize];
        switch (theSettings.imageLocation) {
            case JToastImageLocationLeft:
                label.textAlignment = NSTextAlignmentLeft;
                label.center = CGPointMake(image.size.width +kCompomentPadding * 2 + (v.frame.size.width - image.size.width - kCompomentPadding*2)/2, v.frame.size.height/2);
                break;
            case JToastImageLocationTop:
                [label setTextAlignment:NSTextAlignmentCenter];
                label.center = CGPointMake(v.frame.size.width / 2,
                                           (image.size.height + kCompomentPadding * 2
                                            + (v.frame.size.height - image.size.height - kCompomentPadding * 2) / 2));
                break;
            default:
                break;
        }
    }else{
        v.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 200/375, textSize.height + kCompomentPadding * 2);
        label.center = CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2);
    }
    CGRect LbFm = label.frame;
    LbFm.origin.x = ceil(LbFm.origin.x);
    LbFm.origin.y = ceil(LbFm.origin.y);
    label.frame = LbFm;
    [v addSubview:label];

    if (image) {
        UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
        imageView.frame = [self _frameForImageWithType:type inToastFrame:v.frame];
        [v addSubview:imageView];
    }
    v.backgroundColor = [UIColor colorWithRed:theSettings.bgRed green:theSettings.bgGreen blue:theSettings.bgBlue alpha:theSettings.bgAlpha];
    v.layer.cornerRadius = theSettings.cornerRadius;
    UIWindow *window;
    if ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO){
        window = [[[UIApplication sharedApplication] windows]lastObject];
    }else{
        window = [[[UIApplication sharedApplication]windows]objectAtIndex:0];
    }
    CGPoint point;

    float width = window.frame.size.width;
    float height = window.frame.size.height;

    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation) {
        case UIInterfaceOrientationPortrait://未知方向
            if (theSettings.gravity == jToastGravityTop) {
                point = CGPointMake(window.frame.size.width / 2 , 45);
            }else if(theSettings.gravity == jToastGravityBottom){
                point = CGPointMake(window.frame.size.width / 2, window.frame.size.height - 75);
            }else if (theSettings.gravity == jToastGravityCenter){
                point = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
            }else{
                point = theSettings.position;
            }
            point = CGPointMake(point.x - theSettings.offsetLeft, point.y - theSettings.offsetTop);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            v.transform = CGAffineTransformMakeRotation(M_PI);
            if (theSettings.gravity == jToastGravityTop) {
                point = CGPointMake(width/2, height - 45);
            }else if (theSettings.gravity == jToastGravityBottom){
                point = CGPointMake(width/2, 65);
            }else if(theSettings.gravity == jToastGravityCenter) {
                point = CGPointMake(width/2, height/2);
            }else{
                point = theSettings.position;
            }
            point = CGPointMake(point.x - theSettings.offsetLeft, point.y - theSettings.offsetTop);

            break;
            case UIInterfaceOrientationLandscapeLeft://设备处于横向模式，设备保持直立，右侧Home键。
            v.transform = CGAffineTransformMakeRotation(M_PI/2);
            if (theSettings.gravity == jToastGravityTop) {
                point = CGPointMake(width-45, height/2);
            }else if (theSettings.gravity == jToastGravityBottom){
                point = CGPointMake(45, height/2);
            }else if(theSettings.gravity == jToastGravityCenter) {
                point = CGPointMake(width/2, height/2);
            }else{
                point = theSettings.position;
            }
            point = CGPointMake(point.x - theSettings.offsetLeft, point.y - theSettings.offsetTop);

            break;
        case UIInterfaceOrientationLandscapeRight://设备处于横向模式，设备保持直立，左侧Home键。
            v.transform = CGAffineTransformMakeRotation(-M_PI/2);
            if (theSettings.gravity == jToastGravityTop) {
                point = CGPointMake(45, height/2);
            }else if (theSettings.gravity == jToastGravityBottom){
                point = CGPointMake(width-45, height/2);
            }else if(theSettings.gravity == jToastGravityCenter) {
                point = CGPointMake(width/2, height/2);
            }else{
                point = theSettings.position;
            }
            point = CGPointMake(point.x - theSettings.offsetLeft, point.y - theSettings.offsetTop);

            break;
        default:
            break;
    }
    v.center = point;
    v.frame = CGRectIntegral(v.frame);
    NSTimer *timer1 = [NSTimer timerWithTimeInterval:((float)theSettings.duration)/1000 target:self selector:@selector(hideToast:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop]addTimer:timer1 forMode:NSDefaultRunLoopMode];
    v.tag = CURRENT_TOAST_TAG;
    UIView *currentToast = [window viewWithTag:CURRENT_TOAST_TAG];
    if (currentToast != nil) {
        [currentToast removeFromSuperview];
    }

    v.alpha = 0;
    [window addSubview:v];
    [UIView beginAnimations:nil context:nil];
    v.alpha = 1;
    [UIView commitAnimations];
    self.view = v;
    [window bringSubviewToFront:self.view];
}
-(void)show{
    [self show:(JToastTypeInfo)];
}
-(CGRect)_toastFrameForImageSize:(CGSize)imageSize withLocation:(JToastImageLocation)location andTextSize:(CGSize)textSize{
    CGRect theRect = CGRectZero;
    switch (location) {
        case JToastImageLocationLeft:
            theRect = CGRectMake(0, 0, imageSize.width + textSize.width+kCompomentPadding * 3, MAX(textSize.height, imageSize.height) + kCompomentPadding * 2);
            break;
        case  JToastImageLocationTop:
            theRect = CGRectMake(0, 0, MAX(textSize.width, imageSize.width) + kCompomentPadding * 2 , imageSize.height + textSize.height + kCompomentPadding * 3);
            break;
        default:
            break;
    }
    return theRect;
}
-(CGRect)_frameForImageWithType:(JToastType)type inToastFrame:(CGRect)toastFrame{
    JToastSetting *theSettings = self.settings;
    UIImage *image = [theSettings.images valueForKey:[NSString stringWithFormat:@"%i",type]];
    if(!image) return CGRectZero;
    CGRect imageFrame = CGRectZero;
    switch (theSettings.imageLocation) {
        case JToastImageLocationLeft:
            imageFrame = CGRectMake(kCompomentPadding, (toastFrame.size.height - image.size.height)/2, image.size.width, image.size.height);
            break;
        case JToastImageLocationTop:
            imageFrame = CGRectMake((toastFrame.size.width - image.size.width) / 2, kCompomentPadding, image.size.width, image.size.height);
            break;
        default:
            break;
    }
    return imageFrame;
}
-(void)hideToast:(NSTimer*)theTimer{
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0;
    }];
}
-(void)removeToast:(NSTimer*)theTimer{
    [self.view removeFromSuperview];
}
+(JToast *)makeText:(NSString *)text{
    JToast *toast = [[JToast alloc]initWithText:text];
    return toast;
}
+(void)showText:(NSString *)text{
    JToast *toast = [[JToast alloc]initWithText:text];
    [toast show];
}

- (JToast *) setDuration:(NSInteger ) duration{
    [self theSettings].duration = duration;
    return self;
}
- (JToast *) setGravity:(jToastGravity) gravity
             offsetLeft:(NSInteger) left
              offsetTop:(NSInteger) top{
    [self theSettings].gravity = gravity;
    [self theSettings].offsetLeft = left;
    [self theSettings].offsetTop = top;
    return self;
}
- (JToast *) setGravity:(jToastGravity) gravity{
    [self theSettings].gravity = gravity;
    return self;
}

- (JToast *) setPostion:(CGPoint) _position{
    [self theSettings].position = CGPointMake(_position.x, _position.y);

    return self;
}

- (JToast *) setFontSize:(CGFloat) fontSize{
    [self theSettings].fontSize = fontSize;
    return self;
}

- (JToast *) setUseShadow:(BOOL) useShadow{
    [self theSettings].useShadow = useShadow;
    return self;
}

- (JToast *) setCornerRadius:(CGFloat) cornerRadius{
    [self theSettings].cornerRadius = cornerRadius;
    return self;
}
-(JToast *)setBgBlue:(CGFloat)bgBlue{
    self.theSettings.bgBlue = bgBlue;
    return self;
}
- (JToast *) setBgRed:(CGFloat) bgRed{
    [self theSettings].bgRed = bgRed;
    return self;
}

- (JToast *) setBgGreen:(CGFloat) bgGreen{
    [self theSettings].bgGreen = bgGreen;
    return self;
}
- (JToast *) setBgAlpha:(CGFloat) bgAlpha{
    [self theSettings].bgAlpha = bgAlpha;
    return self;
}

-(JToastSetting *)theSettings{
    if (!_settings) {
        _settings = [JToastSetting getSharedSettings];
    }
    return _settings;
}
@end


@implementation JToastSetting

+(JToastSetting *)getSharedSettings{
    static JToastSetting *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL]init];
        _instance.gravity = jToastGravityCenter;
        _instance.duration = JToastDurationShort;
        _instance.fontSize = 16.0;
        _instance.useShadow = YES;
        _instance.cornerRadius = 5.0;
        _instance.bgRed = 0;
        _instance.bgGreen = 0;
        _instance.bgBlue = 0;
        _instance.bgAlpha = 0.7;
        _instance.offsetLeft = 0;
        _instance.offsetTop = 0;
    });
    return _instance;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    return [JToastSetting getSharedSettings];
}
-(void)setImage:(UIImage *)img withLocation:(JToastImageLocation)location forType:(JToastType)type{
    NSParameterAssert(type);
    if (!_images) {
        _images = [[NSMutableDictionary alloc]initWithCapacity:4];
    }
    if (img) {
        NSString *key = [NSString stringWithFormat:@"%i",type];
        [_images setValue:img forKey:key];
    }
    [self setImageLocation:location];
}
-(void)setImage:(UIImage *)img forType:(JToastType)type{
    [self setImage:img forType:type];
}
@end
