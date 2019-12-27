//
//  PlayViewController.m
//  PlayerDemo
//
//  Created by you&me on 2019/2/21.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import "PlayViewController.h"
#import "JPlayerView.h"
@interface PlayViewController ()<JPlayerViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)JPlayerView *playView;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *dataArr;
@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    [self addSubViews];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        NSLog(@"popopopoppopopo");
        [self.playView stop];
    }
}
-(void)addSubViews{
    [self.view addSubview:self.playView];
    [self.view addSubview:self.tableView];
    [self makeUIFrame];
}
-(void)makeUIFrame{
    self.tableView.frame = CGRectMake(0, 9*[UIScreen mainScreen].bounds.size.width/16, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 9*[UIScreen mainScreen].bounds.size.width/16);
}
#pragma mark - playerView delegate
///是否允许播放
-(BOOL)playerViewShouldPlay{
    return YES;
}

// 当前播放的
- (void)playerView:(JPlayerView *)playView didPlayVideo:(JVideoModel *)videoModel index:(NSInteger)index {


}
// 当前播放结束的
-(void)playerView:(JPlayerView *)playView didPlayerEndVideo:(JVideoModel *)videoModel index:(NSInteger)index{

}
// 当前正在播放的  会调用多次  更新当前播放时间
- (void)playerView:(JPlayerView *)playView didPlayVideo:(JVideoModel *)videoModel playTime:(NSTimeInterval)playTime {


}
-(void)loadData{
    NSArray *titleArr = @[@"视频",@"视频二",@"视频三"];
    NSArray *urlArr = @[[[NSBundle mainBundle] pathForResource:@"play" ofType:@"mp4"],@"http://pgc.cdn.xiaodutv.com/3803535503_2804886108_20190208132400.mp4?Cache-Control%3Dmax-age%3A8640000%26responseExpires%3DSun%2C_19_May_2019_13%3A24%3A09_GMT=&xcode=a6e989fefb9c19ab037f1f0931e3fdd37a1d6056fcbb1479&time=1550821563&_=1550735877809",@"http://pgc.cdn.xiaodutv.com/1339357556_3189957115_2017082919341720170829193824.mp4?authorization=bce-auth-v1%2Fc308a72e7b874edd9115e4614e1d62f6%2F2017-08-29T11%3A50%3A10Z%2F-1%2F%2F1adb213b9af1e58b35b96ac65e683d87a55a7f739e6ca9932401269ab3c88b86&responseCacheControl=max-age%3D8640000&responseExpires=Thu%2C+07+Dec+2017+19%3A50%3A10+GMTmp4&time=1550819532&xcode=04e6b978bd60018e3656d9afe23338a754eb1b169245f491&_=1550735967025"];
    for (int i=0; i<titleArr.count; i++) {
        JVideoModel *model = [[JVideoModel alloc]initWithVideoId:[NSString stringWithFormat:@"%03d",i] title:titleArr[i] url:urlArr[i] currentTime:0];
        [self.dataArr addObject:model];
    }
    [self.playView setVideoModels:self.dataArr playerVideoId:@""];
    [self.tableView reloadData];
}

#pragma mark - tableview delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_ID"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row<_dataArr.count) {
        JVideoModel *model = _dataArr[indexPath.row];
        cell.textLabel.text = model.title;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    JVideoModel *model = _dataArr[indexPath.row];
    [self.playView playVideoWithVideoId:model.videoId];
}
#pragma mark - setter and getter

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell_ID"];
        _tableView.tableFooterView = [[UIView alloc]init];
    }
    return _tableView;
}
-(JPlayerView *)playView{
    if (!_playView) {
        _playView = [[JPlayerView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.width*9/16) currentVC:self];
        self.playView.delegate = self;
    }
    return _playView;
}
-(NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc]init];
    }
    return _dataArr;
}
@end
