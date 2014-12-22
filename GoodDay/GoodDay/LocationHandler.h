//
//  LocationHandler.h
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/22.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const LocationHandlerGetCurrentLocationNotification; // 找到当前位置信息
extern NSString* const LocationHandlerGetLocationFailedNotification; // 查找当前位置失败
extern NSString* const LocationHandlerAuthorizeStatusChangeNotification; // 位置服务授权状态改变

typedef enum
{
    LocationServiceStateAuthorized = 0,
    LocationServiceStateDenied,
    LocationServiceStateRestricted,
    LocationServiceStateNotDetermined,
}LocationServiceState;

@interface LocationHandler : NSObject

@property (nonatomic,readonly,assign) LocationServiceState locationServiceState;

+ (instancetype)sharedHandler;

- (void)startUpdateLocation;

@end
