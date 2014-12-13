//
//  DailyWeatherViewModel.m
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/13.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "DailyWeatherViewModel.h"

@implementation DailyWeatherViewModel

- (instancetype)initWithWeatherModel:(DailyWeatherModel *)model
{
    self = [super init];
    if (self)
    {
        self.icon = [UIImage imageNamed:model.iconImageName];
        self.temperature = [NSString stringWithFormat:@"%ld℃/%ld℃",(long)[model.maxTemperature integerValue],(long)[model.minTemperature integerValue]];
        self.date = [self dateWithTimestamp:model.timestamp];
    }
    return self;
}

- (NSString *)dateWithTimestamp:(NSNumber *)timestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp integerValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd EE";
    return [formatter stringFromDate:date];
}

@end
