//
//  AppDelegate.m
//  wifiTransferFiles
//
//  Created by you&me on 2019/11/21.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "AppDelegate.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "MyHTTPConnection.h"
#import "JIPAddress.h"

@interface AppDelegate ()

@property (nonatomic, strong) HTTPServer * httpServer;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _httpServer = [[HTTPServer alloc] init];
    [_httpServer setPort:1234];
    [_httpServer setType:@"_http._tcp."];
    // webPath是server搜寻HTML等文件的路径
    NSString * webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"web"];
    [_httpServer setDocumentRoot:webPath];
    [_httpServer setConnectionClass:[MyHTTPConnection class]];
    NSError *err;
    if ([_httpServer start:&err]) {
        NSLog(@"port %hu",[_httpServer listeningPort]);
    }else{
        NSLog(@"%@",err);
    }
    NSString *ipStr = [JIPAddress deviceIPAdress];
    NSLog(@"ip地址 %@", ipStr);
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
