//
//  SummaryView.h
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/10.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SummaryView : UIView

@property (nonatomic,weak) IBOutlet UILabel *cityLabel;
@property (nonatomic,weak) IBOutlet UIImageView *icon;
@property (nonatomic,weak) IBOutlet UILabel *conditionLabel;
@property (nonatomic,weak) IBOutlet UILabel *currentTemperatureLabel;
@property (nonatomic,weak) IBOutlet UILabel *floatTemperatureLabel;
@property (weak,nonatomic) IBOutlet UILabel *otherConditionLabel;
@property (weak, nonatomic) IBOutlet UILabel *isCurrentLocationLabel;

- (void)showWeatherWithAnimation:(BOOL)animation;

- (void)clearView;

@end
