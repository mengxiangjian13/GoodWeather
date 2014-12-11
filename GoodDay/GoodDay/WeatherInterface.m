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
    NSURL *sessionUrl = [NSURL URLWithString:url];
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





@end
