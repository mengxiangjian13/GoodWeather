//
//  CityModel.h
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/17.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityModel : NSObject

@property (nonatomic,strong) NSString *backgroundImageName;
@property (nonatomic,strong) NSString *name; // city name
@property (nonatomic,strong) NSString *customName; // show name
@property (nonatomic,strong) NSNumber *lat; // latitude
@property (nonatomic,strong) NSNumber *lon; // longitude
@property (nonatomic,strong) NSString *identifier;
@property (nonatomic,strong) NSString *country;
@property (nonatomic,assign) BOOL isCurrentLocation;

@end
