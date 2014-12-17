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
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "WeatherInterface.h"
#import "CityViewController.h"

@interface RootViewController () <UICollectionViewDataSource,UICollectionViewDelegate,RootCellDelegate>
{
    NSArray *citys;
    
    // data container
    NSMutableDictionary *currentWeatherDict;
    NSMutableDictionary *hourlyForecastDict;
    NSMutableDictionary *dailyForecastDict;
    
    // backgroundImageView
    UIImageView *backgroundImageView;
    // blur
    UIImageView *blurImageView;
    // show citylist button
    UIButton *cityListButton;
    
    // current page
    NSInteger showingPage;
}

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set TSMessage default viewcontroller
    [TSMessage setDefaultViewController:self];
    
    showingPage = 0;
    
    backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundImageView.image = [UIImage imageNamed:@"bg/bg"];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:backgroundImageView];
    
    blurImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    blurImageView.contentMode = UIViewContentModeScaleAspectFill;
    blurImageView.alpha = 0.0;
    [blurImageView setImageToBlur:[UIImage imageNamed:@"bg/bg"]
                       blurRadius:10.0
                  completionBlock:nil];
    [self.view addSubview:blurImageView];
    
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
    
    cityListButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cityListButton setTitle:@"城市" forState:UIControlStateNormal];
    cityListButton.frame = CGRectMake(self.view.bounds.size.width - 50, self.view.bounds.size.height - 44 , 44, 44);
    [cityListButton addTarget:self action:@selector(showCityList:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cityListButton];
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
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.view.bounds.size.width;
    NSInteger page = (NSInteger)ceil((scrollView.contentOffset.x - pageWidth / 2.0) / pageWidth);
    
    if (showingPage != page)
    {
        showingPage = page;
        if (page % 2 == 0)
        {
            backgroundImageView.image = [UIImage imageNamed:@"bg/bg"];
            [blurImageView setImageToBlur:[UIImage imageNamed:@"bg/bg"]
                               blurRadius:10
                          completionBlock:nil];
        }
        else
        {
            backgroundImageView.image = [UIImage imageNamed:@"bg/night.jpg"];
            [blurImageView setImageToBlur:[UIImage imageNamed:@"bg/night.jpg"]
                               blurRadius:10
                          completionBlock:nil];
        }
    }

    NSInteger realPage = (NSInteger)floor(scrollView.contentOffset.x / pageWidth);
    CGFloat line = realPage * pageWidth + pageWidth / 2.0;
    CGFloat alpha = fabs(scrollView.contentOffset.x - line) / (pageWidth / 2.0);
    blurImageView.alpha = 1.0 - alpha;
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
        return;
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

- (void)rootCell:(RootCell *)cell weatherTableViewDidScrollWithContentOffset:(CGPoint)contentOffset
{
    CGFloat offset = MAX(contentOffset.y, 0);
    CGFloat alpha = offset / self.view.bounds.size.height;
    blurImageView.alpha = MIN(alpha, 1.0);
    
    CGFloat translate = MIN(contentOffset.y, 44.0);
    translate = MAX(translate, 0);
    cityListButton.alpha = 1 -  translate / 44.0;
    cityListButton.transform = CGAffineTransformMakeTranslation(0, translate);
}

#pragma mark -
#pragma mark Private Method

- (void)showCityList:(id)sender
{
    NSLog(@"show citys");
    CityViewController *cityListVC = [[CityViewController alloc] initWithCities:citys];
    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:cityListVC];
    [self presentViewController:naviController animated:YES completion:nil];
}

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
