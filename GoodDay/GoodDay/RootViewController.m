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
    
    // data container
    NSMutableDictionary *currentWeatherDict;
    NSMutableDictionary *hourlyForecastDict;
    NSMutableDictionary *dailyForecastDict;
}

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set TSMessage default viewcontroller
    [TSMessage setDefaultViewController:self];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundImageView.image = [UIImage imageNamed:@"Images/bg"];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:backgroundImageView];
    
    //fade data
    citys = @[@"beijing",@"tianjin",@"shanghai",@"chongqing",@"guangzhou",@"shijianzhuang"];

    // data container initialize
    currentWeatherDict = [[NSMutableDictionary alloc] init];
    hourlyForecastDict = [[NSMutableDictionary alloc] init];
    dailyForecastDict = [[NSMutableDictionary alloc] init];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = self.view.bounds.size;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                          collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor clearColor];
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
    return [citys count];
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
    if (currentWeatherDict[city])
    {
        CurrentWeatherViewModel *weather = currentWeatherDict[city];
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
                                                           [self showNetErrorView];
                                                       }];
}

- (void)rootCell:(RootCell *)cell hourlyForecastDataWithShowBlock:(void(^)(NSArray *viewModelArray,BOOL isCache))block
{
    NSInteger index = cell.currentIndex;
    NSString *city = citys[index];
    if (hourlyForecastDict[city])
    {
        NSArray *viewModelArray = hourlyForecastDict[city];
        block(viewModelArray,YES);
        return;
    }
    
    [[WeatherInterface sharedInterface] hourlyforecastWithCity:city
                                                     hourCount:8
                                                       success:^(id model) {
                                                           if ([model isKindOfClass:[NSArray class]])
                                                           {
                                                               NSArray *viewModelArray = (NSArray *)model;
                                                               [hourlyForecastDict setObject:viewModelArray forKey:city];
                                                               // 防止因为重用导致数据不一致
                                                               if (index == cell.currentIndex)
                                                               {
                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                       block(viewModelArray,NO);
                                                                   });
                                                               }
                                                           }
                                                       } failure:^(NSError *error) {
                                                           [self showNetErrorView];
                                                       }];
}

- (void)rootCell:(RootCell *)cell dailyForecastWeatherDataWithShowBlock:(void(^)(NSArray *viewModelArray,BOOL isCache))block
{
    NSInteger index = cell.currentIndex;
    NSString *city = citys[index];
    if (dailyForecastDict[city])
    {
        NSArray *viewModelArray = dailyForecastDict[city];
        block(viewModelArray,YES);
    }
    
    [[WeatherInterface sharedInterface] dailyforecastWithCity:city
                                                     dayCount:7
                                                      success:^(id model) {
                                                          if ([model isKindOfClass:[NSArray class]])
                                                          {
                                                              NSArray *viewModelArray = (NSArray *)model;
                                                              [dailyForecastDict setObject:viewModelArray forKey:city];
                                                              // 防止因为重用导致数据不一致
                                                              if (index == cell.currentIndex)
                                                              {
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      block(viewModelArray,NO);
                                                                  });
                                                              }
                                                          }
                                                      } failure:^(NSError *error) {
                                                          [self showNetErrorView];
                                                      }];
}

#pragma mark -
#pragma mark Private Method

- (void)showNetErrorView
{
    [TSMessage showNotificationWithTitle:@"更新失败"
                                subtitle:@"请检查网络状况是否畅通"
                                    type:TSMessageNotificationTypeError];
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
