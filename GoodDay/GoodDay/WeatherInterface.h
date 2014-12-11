//
//  WeatherInterface.h
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/10.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurrentWeatherViewModel.h"

typedef void (^SuccessBlock)(id model);
typedef void (^FailureBlock)(NSError *error);

@interface WeatherInterface : NSObject

+ (instancetype)sharedInterface;

- (void)currentWeatherWithCity:(NSString *)city
                       success:(SuccessBlock)success
                       failure:(FailureBlock)failure;

@end
