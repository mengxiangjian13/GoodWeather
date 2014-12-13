//
//  DailyWeatherViewModel.h
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/13.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DailyWeatherModel.h"

@interface DailyWeatherViewModel : NSObject

@property (nonatomic,strong) UIImage *icon;
@property (nonatomic,strong) NSString *temperature;
@property (nonatomic,strong) NSString *date;

- (instancetype)initWithWeatherModel:(DailyWeatherModel *)model;

@end
