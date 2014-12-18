//
//  LoadingHud.h
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/18.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingHud : UIView

+ (LoadingHud *)showLoadingHudInView:(UIView *)view;

- (void)hideLoadingHud;

@end
