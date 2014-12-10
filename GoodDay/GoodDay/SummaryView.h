//
//  SummaryView.h
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/10.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SummaryView : UIView

@property (nonatomic,strong) IBOutlet UILabel *cityLabel;
@property (nonatomic,strong) IBOutlet UIImageView *icon;
@property (nonatomic,strong) IBOutlet UILabel *statusLabel;
@property (nonatomic,strong) IBOutlet UILabel *currentTemperatureLabel;
@property (nonatomic,strong) IBOutlet UILabel *floatTemperatureLabel;

@end
