//
//  HourlyWeatherViewModel.m
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/12.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "HourlyWeatherViewModel.h"

@implementation HourlyWeatherViewModel

- (instancetype)initWithWeatherModel:(HourlyWeatherModel *)model
{
    self = [super init];
    if (self)
    {
        self.icon = [UIImage imageNamed:model.iconImageName];
        self.temperature = [NSString stringWithFormat:@"%.1f℃",[model.temperature floatValue]];
        self.date = [self dateWithTimestamp:model.timestamp];
    }
    return self;
}

- (NSString *)dateWithTimestamp:(NSNumber *)timestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp integerValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"h a";
    return [formatter stringFromDate:date];
}

@end
