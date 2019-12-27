//
//  JRouteViewController.m
//  JRoute
//
//  Created by you&me on 2019/2/27.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import "JRouteViewController.h"
#import "JRoute.h"
@interface JRouteViewController ()<JRouteHandler>

@end

@implementation JRouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

+ (void)handleRequestWithParameters:(nullable JParameters)parameters topViewController:(nonnull UIViewController *)topViewController completionHandler:(nullable JCompletionHandler)completionHandler {
    [topViewController presentViewController:[self new] animated:YES completion:nil];
}

+(NSString *)routePath{
    return @"xx";
}
@end
