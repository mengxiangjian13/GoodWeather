//
//  HourlyWeatherModel.h
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/12.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface HourlyWeatherModel : MTLModel <MTLJSONSerializing>

@property (nonatomic,strong) NSNumber *timestamp;
@property (nonatomic,strong) NSString *iconImageName;
@property (nonatomic,strong) NSNumber *temperature;

@end
