//
//  WeatherInterface.m
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/10.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "WeatherInterface.h"

@interface WeatherInterface ()
{
    NSURLSession *session;
}

@end

@implementation WeatherInterface

+ (instancetype)sharedInterface
{
    static dispatch_once_t onceToken;
    static id sharedInterface = nil;
    dispatch_once(&onceToken, ^{
        sharedInterface = [[WeatherInterface alloc] init];
    });
    return sharedInterface;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

- (void)generalRequestWithURL:(NSString *)url
                      success:(SuccessBlock)success
                      failure:(FailureBlock)failure
{
    NSString *absoluteUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *sessionUrl = [NSURL URLWithString:absoluteUrl];
    if (session && sessionUrl)
    {
        NSURLSessionTask *task = [session dataTaskWithURL:sessionUrl
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            if (error || !data)
                                            {
                                                failure(error);
                                            }
                                            else
                                            {
                                                NSError *error = nil;
                                                id object = [NSJSONSerialization JSONObjectWithData:data
                                                                                            options:NSJSONReadingAllowFragments
                                                                                              error:&error];
                                                if (object && !error)
                                                {
                                                    NSLog(@"%@:%@",url,object);
                                                    success(object);
                                                }
                                                else
                                                {
                                                    failure(error);
                                                }
                                            }
                                        }];
        [task resume];
    }
    else
    {
        failure(nil);
    }
}

#pragma mark -
#pragma mark All Interface
- (void)currentWeatherWithCity:(NSString *)city
                       success:(SuccessBlock)success
                       failure:(FailureBlock)failure
{
    NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?q=%@&lang=zh_cn&units=metric",city];
    [self generalRequestWithURL:url
                        success:^(id model) {
                            if ([model isKindOfClass:[NSDictionary class]])
                            {
                                NSDictionary *dict = (NSDictionary *)model;
                                CurrentWeatherModel *model = [MTLJSONAdapter modelOfClass:[CurrentWeatherModel class]
                                                                       fromJSONDictionary:dict
                                                                                    error:nil];
                                CurrentWeatherViewModel *viewModel = [[CurrentWeatherViewModel alloc] initWithWeatherModel:model];
                                success(viewModel);
                            }
                            else
                            {
                                failure(nil);
                            }
                        } failure:^(NSError *error) {
                            failure(error);
                        }];
}

- (void)hourlyforecastWithCity:(NSString *)city
                     hourCount:(NSInteger)count
                       success:(SuccessBlock)success
                       failure:(FailureBlock)failure
{
    NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?q=%@&lang=zh_cn&units=metric",city];
    [self generalRequestWithURL:url
                        success:^(id model) {
                            if ([model isKindOfClass:[NSDictionary class]])
                            {
                                NSDictionary *dict = (NSDictionary *)model;
                                id list = [dict objectForKey:@"list"];
                                if ([list isKindOfClass:[NSArray class]])
                                {
                                    NSArray *_list = (NSArray *)list;
                                    NSArray *modelList = [MTLJSONAdapter modelsOfClass:[HourlyWeatherModel class]
                                                                         fromJSONArray:_list
                                                                                 error:nil];
                                    NSMutableArray *viewModelArray = [[NSMutableArray alloc] init];
                                    // choose hourly weather after now
                                    NSInteger validCount = 0;
                                    for (HourlyWeatherModel *model in modelList)
                                    {
                                        NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
                                        if ([model.timestamp integerValue] > timestamp)
                                        {
                                            HourlyWeatherViewModel *viewModel = [[HourlyWeatherViewModel alloc] initWithWeatherModel:model];
                                            [viewModelArray addObject:viewModel];
                                            ++ validCount;
                                            if (validCount == count)
                                            {
                                                break;
                                            }
                                        }
                                    }
                                    success(viewModelArray);
                                }
                                else
                                {
                                    failure(nil);
                                }
                            }
                            else
                            {
                                failure(nil);
                            }
                        } failure:^(NSError *error) {
                            failure(error);
                        }];
}

- (void)dailyforecastWithCity:(NSString *)city
                     dayCount:(NSInteger)count
                      success:(SuccessBlock)success
                      failure:(FailureBlock)failure
{
    NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?q=%@&lang=zh_cn&units=metric&cnt=%ld",city,(long)count];
    [self generalRequestWithURL:url
                        success:^(id model) {
                            if ([model isKindOfClass:[NSDictionary class]])
                            {
                                NSDictionary *dict = (NSDictionary *)model;
                                id list = [dict objectForKey:@"list"];
                                if ([list isKindOfClass:[NSArray class]])
                                {
                                    NSArray *_list = (NSArray *)list;
                                    NSArray *modelList = [MTLJSONAdapter modelsOfClass:[DailyWeatherModel class]
                                                                         fromJSONArray:_list
                                                                                 error:nil];
                                    NSMutableArray *viewModelArray = [[NSMutableArray alloc] init];
                                    for (DailyWeatherModel *model in modelList)
                                    {
                                        DailyWeatherViewModel *viewModel = [[DailyWeatherViewModel alloc] initWithWeatherModel:model];
                                        [viewModelArray addObject:viewModel];
                                    }
                                    success(viewModelArray);
                                }
                                else
                                {
                                    failure(nil);
                                }
                            }
                            else
                            {
                                failure(nil);
                            }
                        } failure:^(NSError *error) {
                            failure(error);
                        }];
}


@end
