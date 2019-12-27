//
//  JPlayerTitleView.m
//  PlayerDemo
//
//  Created by you&me on 2019/1/30.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import "JPlayerTitleView.h"

@interface JPlayerTitleView ()
@property(nonatomic,strong)UIButton *backButton;
@property(nonatomic,strong)UILabel *titleLabel;
@end
@implementation JPlayerTitleView

-(instancetype)initWithFrame:(CGRect)frame{

    if(self = [super initWithFrame:frame ]){
        self.backgroundColor = Color_RGB_Alpha(0, 0, 0, 0.4);
        [self addSubviews];

    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
}
-(void)addSubviews{
    [self addSubview:self.backButton];
    [self addSubview:self.titleLabel];
}
-(void)makeConstraintsForUI{
    _backButton.frame = CGRectMake(10, 0, 30, self.height);
    _titleLabel.frame = CGRectMake(45, 0, self.width-45-15, self.height);
}
-(void)showBackButton{
    _backButton.hidden = NO;
}
-(void)hideBackButton{
    _backButton.hidden = YES;
}
-(void)clickBackButton:(UIButton*)sender{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(titleViewDidExitFullScreen:)]) {
        [self.delegate titleViewDidExitFullScreen:self];
    }
}

-(UIButton *)backButton{
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"back"] forState:(UIControlStateNormal)];
        [_backButton sizeToFit];
        [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:(UIControlEventTouchUpInside)];
        _backButton.hidden = YES;
    }
    return _backButton;
}
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}
-(void)setTitle:(NSString *)title{
    _title = title;
    _titleLabel.text = _title;
}
@end
