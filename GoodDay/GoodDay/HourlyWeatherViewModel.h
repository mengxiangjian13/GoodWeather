//
//  HourlyWeatherViewModel.h
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/12.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HourlyWeatherModel.h"

@interface HourlyWeatherViewModel : NSObject

@property (nonatomic,strong) UIImage *icon;
@property (nonatomic,strong) NSString *temperature;
@property (nonatomic,strong) NSString *date;

- (instancetype)initWithWeatherModel:(HourlyWeatherModel *)model;

@end
