//
//  ChanceAd.h
//  ChanceAd
//
//  Created by CocoaChina_yangjh on 13-10-15.
//  Copyright (c) 2013年 CocoaChina. All rights reserved.
//

#ifndef ChanceAd_h
#define ChanceAd_h
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CSADRequest.h"
#import "CSRequestError.h"
#import "CSBannerView.h"
#import "CSInterstitial.h"


// SDK_Version仅供参考，以[ChanceAd sdkVersion];得到的版本号为准
#define SDK_Version  @"5.8.0"


@interface ChanceAd : NSObject

/**
 *	@brief	开启会话，在程序启动的时候调用
 *          建议放在协议方法application:didFinishLaunchingWithOptions:中调用
 *
 *	@param 	publisherID 	publisherID
 */
+ (void)startSession:(NSString *)publisherID;

/**
 *	@brief	获取SDK版本号
 *
 *	@return	SDK版本号
 */
+ (NSString *)sdkVersion;

/**
 *	@brief	非越狱设备上是否应用内打开（越狱设备上直接强制跳转）
 *
 *	@param 	openInApp 	YES表示iTunes链接要应用内打开。默认为NO。
 */
+ (void)openInAppWhenNoJailBroken:(BOOL)openInApp;


#pragma mark - Banner

/**
 *	@brief	快捷显示Banner广告
 *
 *	@param 	superView 	父视图
 *	@param 	position 	Banner左上角所在位置
 */
+ (void)showBannerViewOn:(UIView *)superView atPosition:(CGPoint)position;

/**
 *	@brief	移除快捷方式创建的Banner广告
 */
+ (void)removeBannerView;

@end
#endif

