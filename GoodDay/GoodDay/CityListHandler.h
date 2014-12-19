//
//  CityListHandler.h
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/19.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CityModel.h"

@interface CityListHandler : NSObject

+ (NSMutableArray *)mutableCityList;
+ (NSArray *)cityList;
+ (void)addCity:(CityModel *)city;
+ (void)insertCity:(CityModel *)city atIndex:(NSInteger)index;
+ (void)deleteCityAtIndex:(NSInteger)index;
+ (void)exchangeCityAtIndex:(NSInteger)fromIndex withCityAtIndex:(NSInteger)toIndex;
+ (NSInteger)cityListCount;

+ (BOOL)synchronize;

@end
