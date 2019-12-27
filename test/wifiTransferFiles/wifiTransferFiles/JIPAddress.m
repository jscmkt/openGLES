//
//  JIPAddress.m
//  wifiTransferFiles
//
//  Created by you&me on 2019/11/22.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "JIPAddress.h"

@implementation JIPAddress
+(NSString *)deviceIPAdress{
    NSString *address = @"an error occurred when obtating ip adress";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {//0 表示获取成功
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if(temp_addr ->ifa_addr->sa_family == AF_INET){
                ////检查接口是否为en0，即iPhone上的wifi连接
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    //get nsstring from c string
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}
@end
