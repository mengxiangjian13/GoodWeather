//
//  CurrentWeatherViewModel.h
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/11.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CurrentWeatherModel.h"

@interface CurrentWeatherViewModel : NSObject

@property (nonatomic,strong)  UIImage *icon;
@property (nonatomic,strong)  NSString *condition;
@property (nonatomic,strong)  NSString *currentTemperature;
@property (nonatomic,strong)  NSString *floatTemperature;

- (instancetype)initWithWeatherModel:(CurrentWeatherModel *)model;

@end
