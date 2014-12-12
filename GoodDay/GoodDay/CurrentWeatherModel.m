//
//  CurrentWeatherModel.m
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/10.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "CurrentWeatherModel.h"

@implementation CurrentWeatherModel

+ (NSDictionary *)imageMap {
    static NSDictionary *_imageMap = nil;
    if (! _imageMap) {
        _imageMap = @{
                      @"01d" : @"images/weather-clear",
                      @"02d" : @"images/weather-few",
                      @"03d" : @"images/weather-few",
                      @"04d" : @"images/weather-broken",
                      @"09d" : @"images/weather-shower",
                      @"10d" : @"images/weather-rain",
                      @"11d" : @"images/weather-tstorm",
                      @"13d" : @"images/weather-snow",
                      @"50d" : @"images/weather-mist",
                      @"01n" : @"images/weather-moon",
                      @"02n" : @"images/weather-few-night",
                      @"03n" : @"images/weather-few-night",
                      @"04n" : @"images/weather-broken",
                      @"09n" : @"images/weather-shower",
                      @"10n" : @"images/weather-rain-night",
                      @"11n" : @"images/weather-tstorm",
                      @"13n" : @"images/weather-snow",
                      @"50n" : @"images/weather-mist",
                      };
    }
    return _imageMap;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"condition" : @"weather.description",
             @"iconImageName" : @"weather.icon",
             @"currentTemperature" : @"main.temp",
             @"minTemperature" : @"main.temp_min",
             @"maxTemperature" : @"main.temp_max",
             @"windDegree" : @"wind.deg",
             @"windSpeed" : @"wind.speed"};
}

+ (NSValueTransformer *)conditionJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^NSString *(id object) {
        if ([object isKindOfClass:[NSArray class]])
        {
            NSArray *array = (NSArray *)object;
            if ([array count] > 0)
            {
                return array[0];
            }
        }
        return @"";
    }];
}

+ (NSValueTransformer *)iconImageNameJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^NSString *(id object) {
        if ([object isKindOfClass:[NSArray class]])
        {
            NSArray *array = (NSArray *)object;
            if ([array count] > 0)
            {
                NSString *icon = array[0];
                return [CurrentWeatherModel imageMap][icon];
            }
        }
        return @"";
    }];
}




@end
