//
//  SummaryView.m
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/10.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "SummaryView.h"

@implementation SummaryView

- (void)showWeatherWithAnimation:(BOOL)animation
{
    if (!animation)
    {
        return;
    }
    
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIView class]] && obj != self.cityLabel && obj != self.isCurrentLocationLabel)
        {
            UIView *view = (UIView *)obj;
            if (ADBANNER == 1)
            {
                view.transform = CGAffineTransformMakeTranslation(0, 350);
            }
            else
            {
                view.transform = CGAffineTransformMakeTranslation(0, 300);
            }
            double delay = (NSTimeInterval)idx / 5.0;
            [self appearAnimationWithView:view delay:delay];
        }
    }];
}

- (void)appearAnimationWithView:(UIView *)view delay:(NSTimeInterval)delay
{
    [UIView animateWithDuration:0.5
                          delay:delay
                        options:0
                     animations:^{
                         view.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         ;
                     }];
}

- (void)clearView
{
    self.cityLabel.text = nil;
    self.icon.image = nil;
    self.conditionLabel.text = nil;
    self.floatTemperatureLabel.text = nil;
    self.otherConditionLabel.text = nil;
    self.currentTemperatureLabel.text = nil;
    self.isCurrentLocationLabel.text = nil;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
