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
    self.floatTemperature = [NSString stringWithFormat:@"%.1f℃ / %.1f ℃",model.maxTemperature.floatValue,model.minTemperature.floatValue];
}

@end
