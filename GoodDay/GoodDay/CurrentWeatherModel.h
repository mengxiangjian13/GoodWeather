//
//  CurrentWeatherModel.h
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/10.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface CurrentWeatherModel : MTLModel <MTLJSONSerializing>

@property (nonatomic,strong) NSString *iconImageName;
@property (nonatomic,strong) NSString *condition;
@property (nonatomic,strong) NSNumber *currentTemperature;
@property (nonatomic,strong) NSNumber *minTemperature;
@property (nonatomic,strong) NSNumber *maxTemperature;
@property (nonatomic,strong) NSNumber *windDegree;
@property (nonatomic,strong) NSNumber *windSpeed;


@end
