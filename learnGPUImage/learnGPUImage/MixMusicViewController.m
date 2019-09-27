//
//  MixMusicViewController.m
//  learnGPUImage
//
//  Created by you&me on 2019/9/16.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "MixMusicViewController.h"
#import <GPUImage.h>
#import "THImageMovie.h"
#import "THImageMovieWriter.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface MixMusicViewController ()
@property(nonatomic,strong)UILabel *mLabel;
@property(nonatomic,strong)THImageMovieWriter *movieWriter;
@property(nonatomic) dispatch_group_t recordSyncingDispatchGroup;
@end

@implementation MixMusicViewController{
    THImageMovie *movieFile;
    THImageMovie *movieFile2;
    GPUImageOutput<GPUImageInput> *filter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    GPUImageView *filterView = [[GPUImageView alloc]initWithFrame:self.view.bounds];
    self.view = filterView;

    self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
    self.mLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.mLabel];

    filter = [[GPUImageDissolveBlendFilter alloc] init];
    [(GPUImageDissolveBlendFilter *)filter setMix:0.5];

    //播放
    NSURL *sampleURL = [[NSBundle mainBundle]URLForResource:@"abc" withExtension:@"mp4"];
    movieFile = [[THImageMovie alloc]initWithURL:sampleURL];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = YES;

    NSURL *sampleURL2 = [[NSBundle mainBundle]URLForResource:@"def" withExtension:@"mp4"];
    movieFile2 = [[THImageMovie alloc]initWithURL:sampleURL2];
    movieFile2.runBenchmark = YES;
    movieFile2.playAtActualSpeed = YES;

    NSArray *thMovies = @[movieFile,movieFile2];

    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];

    self.movieWriter = [[THImageMovieWriter alloc]initWithMovieURL:movieURL size:CGSizeMake(640, 480) movies:thMovies];

    //响应链
    [movieFile addTarget:filter];
    [movieFile2 addTarget:filter];

    //显示到界面
    [filter addTarget:filterView];
    [filter addTarget:_movieWriter];

    [movieFile2 startProcessing];
    [movieFile startProcessing];
    [_movieWriter startRecording];

    CADisplayLink *dlink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    [dlink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [dlink setPaused:NO];

    __weak typeof(self) weakSelf = self;
    [_movieWriter setCompletionBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->filter removeTarget:strongSelf->_movieWriter];
        [strongSelf->movieFile endProcessing];
        [strongSelf->movieFile2 endProcessing];

        ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToMovie)) {
            [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    if (error) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存失败" message:nil
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存成功" message:nil
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                });
            }];
        }else{
            NSLog(@"error mssg");
        }
    }];
}



- (void)updateProgress
{
    self.mLabel.text = [NSString stringWithFormat:@"Progress:%d%%", (int)(movieFile.progress * 100)];
    [self.mLabel sizeToFit];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
