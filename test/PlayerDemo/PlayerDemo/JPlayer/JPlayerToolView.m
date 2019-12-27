//
//  JPlayerToolView.m
//  PlayerDemo
//
//  Created by you&me on 2019/2/2.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import "JPlayerToolView.h"
#import "JPlayerHeader.h"
@implementation JPlayerToolView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = Color_RGB_Alpha(0, 0, 0, 0.4);
        [self addSubviews];
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [self makeConstraintsForUI];
}
#pragma mark - add subviews

-(void)addSubviews{
    [self addSubview:self.playSwitch];
    [self addSubview:self.fullScreen];
    [self addSubview:self.currentTimeLB];
    [self addSubview:self.totleTimeLabel];
    [self addSubview:self.slider];
}

#pragma mark - make constraints
-(void)makeConstraintsForUI{
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    _playSwitch.frame = CGRectMake(10, (height-30)/2, 30, 30);
    _currentTimeLB.frame = CGRectMake( CGRectGetMaxX(_playSwitch.frame) + 5 , 0 , 50 , height);
    _fullScreen.frame = CGRectMake(width -40, 0, 30, height);
    _totleTimeLabel.frame = CGRectMake(CGRectGetMinX(_fullScreen.frame)-5-50, 0, 50, height);
    _slider.frame = CGRectMake(CGRectGetMaxX(_currentTimeLB.frame) + 10, 0, CGRectGetMinX(_totleTimeLabel.frame) - CGRectGetMaxX(_currentTimeLB.frame) - 10, height);
}
-(void)exitFullScreen{
    [self clickFullScreen:self.fullScreen];
}

#pragma mark - button event
-(void)clickPlaySwitch:(UIButton*)sender{
    sender.selected = !sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolView:playSwith:)]) {
        [self.delegate toolView:self playSwith:sender.selected];
    }
}
-(void)clickFullScreen:(UIButton*)sender{
    sender.selected = !sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolView:fullScreen:)]) {
        [self.delegate toolView:self fullScreen:sender.selected];
    }
}

#pragma mark - setter and getter
-(UIButton *)playSwitch{
    if (!_playSwitch) {
        UIButton *playSwitch = [[UIButton alloc]init];
        [playSwitch setImage:[UIImage imageNamed:@"video_play"] forState:(UIControlStateNormal)];
        [playSwitch setImage:[UIImage imageNamed:@"video_pause"] forState:(UIControlStateSelected)];
        [playSwitch addTarget:self action:@selector(clickPlaySwitch:) forControlEvents:(UIControlEventTouchUpInside)];
        _playSwitch = playSwitch;
    }
    return _playSwitch;
}
-(UIButton *)fullScreen{
    if (!_fullScreen) {
        _fullScreen = [[UIButton alloc]init];
        [_fullScreen setImage:[UIImage imageNamed:@"screen_full"] forState:(UIControlStateNormal)];
        [_fullScreen setImage:[UIImage imageNamed:@"screen_unfull"] forState:(UIControlStateSelected)];
        [_fullScreen addTarget:self action:@selector(clickFullScreen:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _fullScreen;
}
-(UILabel *)currentTimeLB{
    if (!_currentTimeLB) {
        _currentTimeLB = [[UILabel alloc]init];
        _currentTimeLB.textColor = [UIColor whiteColor];
        _currentTimeLB.font = [UIFont systemFontOfSize:12];
        _currentTimeLB.textAlignment = NSTextAlignmentCenter;
        _currentTimeLB.text = @"00:00";
    }
    return _currentTimeLB;
}

-(UILabel *)totleTimeLabel{
    if (!_totleTimeLabel) {
        _totleTimeLabel = [[UILabel alloc]init];
        _totleTimeLabel.textColor = [UIColor whiteColor];
        _totleTimeLabel.font = [UIFont systemFontOfSize:12];
        _totleTimeLabel.textAlignment = NSTextAlignmentCenter;
        _totleTimeLabel.text = @"00:00";
    }
    return _totleTimeLabel;
}

-(JProgressSlider *)slider{
    if (!_slider) {
        _slider = [[JProgressSlider alloc]initWithFrame:CGRectZero direction:JSliderDirectionHorizonal];
        _slider.enabled = NO;
    }
    return _slider;
}
@end
