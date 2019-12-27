//
//  JRouteRequest.m
//  JRoute
//
//  Created by you&me on 2019/2/26.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import "JRouteRequest.h"
#import <objc/message.h>

@interface JRouteRequest ()
@property (nonatomic,strong,readonly,nullable)NSURL *originalURL;
@end
@implementation JRouteRequest

-(instancetype)initWithPath:(NSString *)requestPath parameters:(JParameters)parameters
{
    NSParameterAssert(requestPath);
    if (self = [super init]) {
        while ([requestPath hasPrefix:@"/"]) {
            requestPath = [requestPath substringFromIndex:1];
        }
        _requestPath = requestPath.copy?:@"";
        _prts = parameters;

    }
    return self;
}

@end

@implementation JRouteRequest (CreatByURL)

-(instancetype)initWithURL:(NSURL *)URL{
    JParameters parameters = nil;
    NSURLComponents *c = [[NSURLComponents alloc]initWithURL:URL resolvingAgainstBaseURL:YES];
    if (0 !=c.queryItems.count) {
        NSMutableDictionary *m = @{}.mutableCopy;
        for (NSURLQueryItem *item in c.queryItems) {
            m[item.name] = item.value;
        }
        parameters = m.copy;
    }
    self = [self initWithPath:URL.path.stringByDeletingPathExtension parameters:parameters];
    if (self) {
        _originalURL = URL;
    }
    return self;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"[%@<%p>] {\n \
            requestPath = %@; \n \
            parameters = %@; \n \
            originalURL = %@; \n \
            }",NSStringFromClass([self class]),self,_requestPath,_prts,_originalURL];
}
@end
