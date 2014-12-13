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
                      @"01d" : @"Images/weather-clear",
                      @"02d" : @"Images/weather-few",
                      @"03d" : @"Images/weather-few",
                      @"04d" : @"Images/weather-broken",
                      @"09d" : @"Images/weather-shower",
                      @"10d" : @"Images/weather-rain",
                      @"11d" : @"Images/weather-tstorm",
                      @"13d" : @"Images/weather-snow",
                      @"50d" : @"Images/weather-mist",
                      @"01n" : @"Images/weather-moon",
                      @"02n" : @"Images/weather-few-night",
                      @"03n" : @"Images/weather-few-night",
                      @"04n" : @"Images/weather-broken",
                      @"09n" : @"Images/weather-shower",
                      @"10n" : @"Images/weather-rain-night",
                      @"11n" : @"Images/weather-tstorm",
                      @"13n" : @"Images/weather-snow",
                      @"50n" : @"Images/weather-mist",
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
