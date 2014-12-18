//
//  FindCityViewController.h
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/17.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FindCityViewControllerDelegate <NSObject>

- (void)findCityViewControllerDidFindCityWithCity:(NSString *)city;

@end

@interface FindCityViewController : UIViewController <UISearchResultsUpdating>

@property (nonatomic,weak) id <FindCityViewControllerDelegate> delegate;

@end
