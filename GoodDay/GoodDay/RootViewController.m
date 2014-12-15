//
//  RootViewController.m
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/15.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "RootViewController.h"
#import "RootCell.h"
#import <TSMessages/TSMessage.h>
#import "WeatherInterface.h"

@interface RootViewController () <UICollectionViewDataSource,UICollectionViewDelegate,RootCellDelegate>
{
    NSArray *citys;
    NSMutableDictionary *currentWeatherDict;
}

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //fade data
    citys = @[@"beijing",@"tianjin",@"shanghai",@"chongqing",@"guangzhou",@"shijianzhuang"];

    currentWeatherDict = [[NSMutableDictionary alloc] init];
    for (NSString *city in citys)
    {
        [currentWeatherDict setObject:[NSNull null] forKey:city];
    }
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = self.view.bounds.size;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                          collectionViewLayout:flowLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    collectionView.pagingEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    
    [collectionView registerClass:[RootCell class]
       forCellWithReuseIdentifier:@"cell"];
    
    [self.view addSubview:collectionView];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [currentWeatherDict count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RootCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell"
                                                                           forIndexPath:indexPath];
    cell.delegate = self;
    [cell showWeatherForecastWithIndex:indexPath.item city:citys[indexPath.item]];
    
    return cell;
}

#pragma mark -
#pragma mark RootCellDelegate
- (void)rootCell:(RootCell *)cell currentWeatherDataWithShowBlock:(void(^)(CurrentWeatherViewModel *model,BOOL isCache))block
{
    NSInteger index = cell.currentIndex;
    NSString *city = citys[index];
    if ([currentWeatherDict objectForKey:city] != [NSNull null])
    {
        CurrentWeatherViewModel *weather = [currentWeatherDict objectForKey:city];
        block(weather,YES);
        return;
    }
    
    [[WeatherInterface sharedInterface] currentWeatherWithCity:city
                                                       success:^(id model) {
                                                           if ([model isKindOfClass:[CurrentWeatherViewModel class]])
                                                           {
                                                               CurrentWeatherViewModel *weather = (CurrentWeatherViewModel *)model;
                                                               [currentWeatherDict setObject:model
                                                                                      forKey:city];
                                                               // 防止因为重用导致数据不一致
                                                               if (index == cell.currentIndex)
                                                               {
                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                       block(weather,NO);
                                                                   });
                                                               }
                                                           }
                                                       } failure:^(NSError *error) {
                                                           [TSMessage showNotificationWithTitle:@"更新失败"
                                                                                       subtitle:@"请检查网络状况是否畅通"
                                                                                           type:TSMessageNotificationTypeError];
                                                       }];
}

#pragma statusbar

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
