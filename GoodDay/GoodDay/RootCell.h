//
//  RootCell.h
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/15.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurrentWeatherViewModel.h"
#import "HourlyWeatherViewModel.h"
#import "DailyWeatherViewModel.h"

@protocol RootCellDelegate;

@interface RootCell : UICollectionViewCell

@property (nonatomic,assign) NSInteger currentIndex;
@property (nonatomic,weak) id <RootCellDelegate> delegate;

- (void)showWeatherForecastWithIndex:(NSInteger)index city:(NSString *)city;

@end

@protocol RootCellDelegate <NSObject>

- (void)rootCell:(RootCell *)cell currentWeatherDataWithShowBlock:(void(^)(CurrentWeatherViewModel *model,BOOL isCache))block;

@end