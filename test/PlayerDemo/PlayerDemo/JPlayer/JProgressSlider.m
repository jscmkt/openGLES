//
//  JProgressSlider.m
//  PlayerDemo
//
//  Created by you&me on 2019/2/2.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import "JProgressSlider.h"
#import "JPlayerHeader.h"
@interface JProgressSlider ()
///整条线的颜色
@property(nonatomic)UIColor *lineColor;
///滑动的线的颜色
@property(nonatomic)UIColor *slidedLineColor;
///预加载线的颜色
@property(nonatomic)UIColor *progressLineColor;
///圆的颜色
@property(nonatomic)UIColor *circleColor;

///线的宽度
@property(nonatomic,assign)CGFloat lineWith;
///远的半径
@property(nonatomic,assign)CGFloat circleRadius;
@end
@implementation JProgressSlider
-(instancetype)initWithFrame:(CGRect)frame direction:(JSliderDirection)direction{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _minValue = 0;
        _maxValue = 1;
        _direction = direction;
        _lineColor = [UIColor whiteColor];
        _slidedLineColor = Color_RGB(255, 130, 86);
        _circleColor = [UIColor whiteColor];
        _progressLineColor = [UIColor grayColor];
        _sliderPercent = 0.0;
        _lineWith = 2;
        _circleRadius = 6;

    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [self setNeedsDisplay];
}
-(void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    //画总体的线
    //画笔颜色
    CGContextSetStrokeColorWithColor(context, _lineColor.CGColor);
    //线宽度
    CGContextSetLineWidth(context, _lineWith);

    //起点
    CGFloat startLineX = (_direction == JSliderDirectionHorizonal ? _circleRadius : (self.frame.size.width-_lineWith)/2);
    CGFloat startLineY = (_direction == JSliderDirectionHorizonal ? (self.frame.size.height - _lineWith)/2 : _circleRadius);

    //终点
    CGFloat endLineX = (_direction == JSliderDirectionHorizonal ? self.frame.size.width - _circleRadius : (self.frame.size.width-_lineWith)/2);
    CGFloat endLineY = (_direction == JSliderDirectionHorizonal ? (self.frame.size.height - _lineWith)/2 : self.frame.size.height - _circleRadius);
    CGContextMoveToPoint(context, startLineX, startLineY);
    CGContextAddLineToPoint(context, endLineX, endLineY);
    CGContextClosePath(context);
    CGContextStrokePath(context);


    //绘制缓冲进度的线
    //画笔颜色
    CGContextSetStrokeColorWithColor(context, _progressLineColor.CGColor);
    //线的宽度
    CGContextSetLineWidth(context, _lineWith);

    CGFloat progressLineX = (_direction == JSliderDirectionHorizonal ? MAX(_circleRadius, (_progressPrecent * self.frame.size.width - _circleRadius)) : startLineX);
    CGFloat progressLineY = (_direction == JSliderDirectionHorizonal ? startLineY : MAX(_circleRadius, (_progressPrecent * self.frame.size.height - _circleRadius)));
    CGContextMoveToPoint(context, startLineX, startLineY);
    CGContextAddLineToPoint(context, progressLineX, progressLineY);
    CGContextClosePath(context);
    CGContextStrokePath(context);

    //画已滑动进度的线
    //画笔颜色
    CGContextSetStrokeColorWithColor(context, _slidedLineColor.CGColor);
    //线的宽度
    CGContextSetLineWidth(context, _lineWith);

    CGFloat slidedLineX = (_direction == JSliderDirectionHorizonal ? MAX(_circleRadius, (_sliderPercent * (self.frame.size.width - 2 * _circleRadius) + _circleRadius)) : startLineX);
    CGFloat slidedLineY = (_direction == JSliderDirectionHorizonal ? startLineY : MAX(_circleRadius, (_sliderPercent * self.frame.size.height - _circleRadius)));

    CGContextMoveToPoint(context, startLineX, startLineY);
    CGContextAddLineToPoint(context, slidedLineX, slidedLineY);
    CGContextClosePath(context);
    CGContextStrokePath(context);

    //画圆
    CGFloat penWidth = 1.f;
    CGFloat circleX = (_direction == JSliderDirectionHorizonal ? MAX(_circleRadius + penWidth, slidedLineX - penWidth) : startLineX);
    CGFloat circleY = (_direction == JSliderDirectionHorizonal ? startLineY : MAX(_circleRadius + penWidth, slidedLineY - penWidth));

    CGContextSetStrokeColorWithColor(context, nil);
    CGContextSetLineWidth(context, 0);
    CGContextSetFillColorWithColor(context, _circleColor.CGColor);
    CGContextAddArc(context, circleX, circleY, _circleRadius, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathFillStroke);

}


#pragma mark - touch event
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.enabled) {
        return;
    }
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:NO];
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.enabled) {
        return;
    }
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:NO];
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.enabled) {
        return;
    }
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:YES];
}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.enabled) {
        return;
    }
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:YES];
}


-(void)updateTouchPoint:(NSSet*)touches{
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    self.sliderPercent = (_direction == JSliderDirectionHorizonal ? touchPoint.x : touchPoint.y) / (_direction == JSliderDirectionHorizonal ? self.frame.size.width : self.frame.size.height);
}

-(void)callbackTouchEnd:(BOOL)isTouchEnd{
    _isSliding = !isTouchEnd;
    if (isTouchEnd == YES) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}


#pragma mark - setter

-(void)setSliderPercent:(CGFloat)sliderPercent{
    if (_sliderPercent != sliderPercent) {
        _sliderPercent = sliderPercent;
        self.value = _minValue + sliderPercent * (_maxValue - _minValue);
    }
}
-(void)setProgressPrecent:(CGFloat)progressPrecent{
    if (_progressPrecent != progressPrecent) {
        _progressPrecent = progressPrecent;
        [self setNeedsDisplay];
    }
}
-(void)setValue:(CGFloat)value{
    if (value != _value) {
        if (value < _minValue) {
            _value = _minValue;
            return;
        }else if(value > _maxValue){
            _value = _maxValue;
            return;
        }
        _value = value;
        _sliderPercent = (_value - _minValue)/_maxValue - _minValue;
        [self setNeedsDisplay];
    }
}
@end
