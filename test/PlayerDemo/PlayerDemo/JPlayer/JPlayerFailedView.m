//
//  JPlayerFailedView.m
//  PlayerDemo
//
//  Created by you&me on 2019/1/29.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import "JPlayerFailedView.h"

@interface JPlayerFailedView ()
    @property(nonatomic,strong)UIButton *reloadbutton;
@end

@implementation JPlayerFailedView

    -(instancetype)initWithFrame:(CGRect)frame{
        if (self = [super initWithFrame:frame]) {
            self.backgroundColor = [UIColor blackColor];
            [self addSubview:self.reloadbutton];
        }
        return self;
    }

    - (void)layoutSubviews{
        [super layoutSubviews];
        _reloadbutton.frame = CGRectMake(0, 40, self.bounds.size.width, 40);
        _reloadbutton.centerY = self.centerY;
    }
    -(void)clickReloadButton:(UIButton*)sender{
        if (self.delegate && [self.delegate respondsToSelector:@selector(failedViewDidReplay:)]) {
            [self.delegate failedViewDidReplay:self];
        }
    }
    -(UIButton *)reloadbutton{
        if (!_reloadbutton) {
            UIButton *button = [[UIButton alloc]init];
            [button setTitle:@"视频加载失败，点击重新加载" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(clickReloadButton:) forControlEvents:(UIControlEventTouchUpInside)];
            _reloadbutton = button;
        }
        return _reloadbutton;
    }
@end
