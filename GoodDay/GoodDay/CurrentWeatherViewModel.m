//
//  CurrentWeatherViewModel.m
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/11.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "CurrentWeatherViewModel.h"

@implementation CurrentWeatherViewModel

- (instancetype)initWithWeatherModel:(CurrentWeatherModel *)model
{
    self = [super init];
    if (self)
    {
        [self setupViewModel:model];
    }
    return self;
}

- (void)setupViewModel:(CurrentWeatherModel *)model
{
    if (!model)
    {
        return;
    }
    
    self.icon = [UIImage imageNamed:model.iconImageName];
    self.condition = model.condition;
    self.currentTemperature = [NSString stringWithFormat:@"%.1f ℃",model.currentTemperature.floatValue];
    self.floatTemperature = [NSString stringWithFormat:@"%.1f℃ / %.1f℃",model.maxTemperature.floatValue,model.minTemperature.floatValue];
    self.otherCondition = [NSString stringWithFormat:@"%@ %.1fm/s",[self windDirectionWithDegree:model.windDegree],[model.windSpeed floatValue]];
}

- (NSString *)windDirectionWithDegree:(NSNumber *)degree
{
    float degreef = [degree floatValue];
    if (degreef > 22.5 && degreef < 67.5)
    {
        return @"东北风";
    }
    else if (degreef >= 67.5 && degreef <= 112.5)
    {
        return @"东风";
    }
    else if (degreef > 112.5 && degreef < 157.5)
    {
        return @"东南风";
    }
    else if (degreef >= 157.5 && degreef <= 202.5)
    {
        return @"南风";
    }
    else if (degreef > 202.5 && degreef < 247.5)
    {
        return @"西南风";
    }
    else if (degreef >= 247.5 && degreef <= 292.5)
    {
        return @"西风";
    }
    else if (degreef > 292.5 && degreef < 337.5)
    {
        return @"西北风";
    }
    return @"北风";
}

@end
