//
//  WeatherInterface.h
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/10.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurrentWeatherViewModel.h"
#import "HourlyWeatherViewModel.h"
#import "DailyWeatherViewModel.h"
#import "CityModel.h"


typedef void (^SuccessBlock)(id model);
typedef void (^FailureBlock)(NSError *error);

@interface WeatherInterface : NSObject

+ (instancetype)sharedInterface;

- (void)currentWeatherWithCity:(NSString *)city
                       success:(SuccessBlock)success
                       failure:(FailureBlock)failure;

- (void)hourlyforecastWithCity:(NSString *)city
                     hourCount:(NSInteger)count
                       success:(SuccessBlock)success
                       failure:(FailureBlock)failure;

- (void)dailyforecastWithCity:(NSString *)city
                    dayCount:(NSInteger)count
                    success:(SuccessBlock)success
                    failure:(FailureBlock)failure;

- (void)findCityWithCityName:(NSString *)city
                     success:(SuccessBlock)success
                     failure:(FailureBlock)failure;
@end
