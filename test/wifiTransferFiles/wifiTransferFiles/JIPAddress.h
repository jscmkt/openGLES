//
//  JIPAddress.h
//  wifiTransferFiles
//
//  Created by you&me on 2019/11/22.
//  Copyright © 2019 you&me. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
NS_ASSUME_NONNULL_BEGIN

@interface JIPAddress : NSObject
///getdevice ip address
+(NSString *)deviceIPAdress;
@end

NS_ASSUME_NONNULL_END
