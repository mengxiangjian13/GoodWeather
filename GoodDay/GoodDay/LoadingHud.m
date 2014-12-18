//
//  LoadingHud.m
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/18.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "LoadingHud.h"

@implementation LoadingHud

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        shadow.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [self addSubview:shadow];
        
        [self addCircleAnimation];
    }
    return self;
}

- (void)addCircleAnimation
{
    [self addImageViewWithImage:[UIImage imageNamed:@"Images/weather-clear"] rotationIsReverse:NO];
    [self addImageViewWithImage:[UIImage imageNamed:@"Images/weather-moon"] rotationIsReverse:YES];
}

- (void)addImageViewWithImage:(UIImage *)image rotationIsReverse:(BOOL)isReverse
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    imageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    imageView.image = image;
    [self addSubview:imageView];
    
    CAKeyframeAnimation *circle = [CAKeyframeAnimation animation];
    circle.keyPath = @"position";
    circle.duration = 1.0;
    circle.repeatCount = HUGE_VALF;
    circle.additive = YES;
    if (isReverse)
    {
        CGMutablePathRef reverseCircle = CGPathCreateMutable();
        CGPathAddArc(reverseCircle, NULL, 0, 0, 25, -M_PI, 0, true);
        CGPathAddArc(reverseCircle, NULL, 0, 0, 25, 0, M_PI, true);
        CGPathCloseSubpath(reverseCircle);
        circle.path = reverseCircle;
        CGPathRelease(reverseCircle);
    }
    else
    {
        CGMutablePathRef normalCircle = CGPathCreateMutable();
        CGPathAddArc(normalCircle, NULL, 0, 0, 25, 0, 2*M_PI, true);
        CGPathCloseSubpath(normalCircle);
        circle.path = normalCircle;
        CGPathRelease(normalCircle);
    }
    circle.calculationMode = kCAAnimationPaced;//设置了paced就忽略了keytimes
    
    [imageView.layer addAnimation:circle forKey:@"circle"];
}

+ (LoadingHud *)showLoadingHudInView:(UIView *)view
{
    LoadingHud *hud = [[LoadingHud alloc] initWithFrame:view.bounds];
    [view addSubview:hud];
    return hud;
}

- (void)hideLoadingHud
{
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.alpha = 0.0;
                     }completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

@end
