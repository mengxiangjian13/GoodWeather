//
//  DailyWeatherModel.h
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/13.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface DailyWeatherModel : MTLModel <MTLJSONSerializing>

@property (nonatomic,strong) NSNumber *minTemperature;
@property (nonatomic,strong) NSNumber *maxTemperature;
@property (nonatomic,strong) NSNumber *timestamp;
@property (nonatomic,strong) NSString *iconImageName;

@end
