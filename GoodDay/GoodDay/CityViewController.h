//
//  CityViewController.h
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/14.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CityViewControllerDelegate <NSObject>

- (void)cityViewControllerDidEndEditing;

@end

@interface CityViewController : UIViewController

@property (nonatomic,weak) id <CityViewControllerDelegate> delegate;

@end
