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
        if ([obj isKindOfClass:[UIView class]] && obj != self.cityLabel)
        {
            UIView *view = (UIView *)obj;
            view.transform = CGAffineTransformMakeTranslation(0, 300);
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



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
