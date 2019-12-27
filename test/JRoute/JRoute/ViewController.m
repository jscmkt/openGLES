//
//  ViewController.m
//  JRoute
//
//  Created by you&me on 2019/2/26.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import "ViewController.h"
#import "JRoute.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor redColor];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    JRouteRequest *request = [[JRouteRequest alloc]initWithPath:@"xx" parameters:nil];
    [JRoute.shared handleRequest:request completionHandler:nil];
}

@end
