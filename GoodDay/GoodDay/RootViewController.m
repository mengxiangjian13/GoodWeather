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
#import "CSBannerView.h"
#import "CityListHandler.h"
#import "LocationHandler.h"

@interface RootViewController () <UICollectionViewDataSource,UICollectionViewDelegate,RootCellDelegate,CityViewControllerDelegate>
{
    NSMutableArray *citys;
    
    // data container
    NSMutableDictionary *currentWeatherDict;
    NSMutableDictionary *hourlyForecastDict;
    NSMutableDictionary *dailyForecastDict;
    
    // main collectionView
    UICollectionView *collectionView;
    
    // backgroundImageView
    UIImageView *backgroundImageView;
    // blur
    UIImageView *blurImageView;
    // show citylist button
    UIButton *cityListButton;
    
    // current page
    NSInteger showingPage;
    NSInteger previousPage;
    
    // ad banner
    CSBannerView *bannerView;
}

@end

@implementation RootViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self coreLocationAuthorizeStatusChange];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set TSMessage default viewcontroller
    [TSMessage setDefaultViewController:self];
    
    showingPage = 0;
    previousPage = 0;
    
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
    if ([[LocationHandler sharedHandler] locationServiceState] == LocationServiceStateDenied ||
        [[LocationHandler sharedHandler] locationServiceState] == LocationServiceStateRestricted)
    {
        citys = [[NSMutableArray alloc] initWithArray:[CityListHandler cityList]];
    }
    else
    {
        citys = [[NSMutableArray alloc] init];
    }

    // data container initialize
    currentWeatherDict = [[NSMutableDictionary alloc] init];
    hourlyForecastDict = [[NSMutableDictionary alloc] init];
    dailyForecastDict = [[NSMutableDictionary alloc] init];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = self.view.bounds.size;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                          collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    collectionView.pagingEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    
    [collectionView registerClass:[RootCell class]
       forCellWithReuseIdentifier:@"cell"];
    
    [self.view addSubview:collectionView];
    
    cityListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cityListButton setImage:[UIImage imageNamed:@"Images/menu"] forState:UIControlStateNormal];
    cityListButton.frame = CGRectMake(self.view.bounds.size.width - 60, 24, 44, 44);
    [cityListButton addTarget:self action:@selector(showCityList:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cityListButton];

#if ADBANNER==1
    bannerView = [[CSBannerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 50, CSBannerSize_iPhone.width, CSBannerSize_iPhone.height)];
    CSADRequest *adRequest = [CSADRequest requestWithRequestInterval:20.0f andDisplayTime:20.0f];
    [bannerView loadRequest:adRequest];
    [self.view addSubview:bannerView];
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityViewControllerDidEndEditing) name:LocationHandlerGetCurrentLocationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreLocationAuthorizeStatusChange)
                                                 name:LocationHandlerAuthorizeStatusChangeNotification object:nil];
    
}

- (void)showNoCityAlert
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"您还没有关注的任何城市"
                                                                     message:@"添加自选城市，开始您的世界旅途吧。"
                                                              preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *add = [UIAlertAction actionWithTitle:@"去添加城市"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    [self showCityList:nil];
                                                }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"我不想添加"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction *action) {
                                                    ;
                                                }];
    
    [alertVC addAction:add];
    [alertVC addAction:cancel];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)coreLocationAuthorizeStatusChange
{
    if ([[LocationHandler sharedHandler] locationServiceState] == LocationServiceStateDenied ||
        [[LocationHandler sharedHandler] locationServiceState] == LocationServiceStateRestricted)
    {
        if ([citys count] == 0)
        {
            [self showCityList:nil];
        }
    }
}

#pragma mark -
#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)_collectionView numberOfItemsInSection:(NSInteger)section
{
    return [citys count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)_collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RootCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"cell"
                                                                forIndexPath:indexPath];
    cell.delegate = self;
    CityModel *city = citys[indexPath.item];
    [cell showWeatherForecastWithIndex:indexPath.item city:city.customName isCurrentLocation:city.isCurrentLocation];
    
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // move cityButton and adBanner to origin position
    if (previousPage != showingPage)
    {
        previousPage = showingPage;
        [UIView animateWithDuration:0.5
                         animations:^{
                             cityListButton.transform = CGAffineTransformIdentity;
                             if (bannerView)
                             {
                                 bannerView.transform = CGAffineTransformIdentity;
                             }
                         }];
    }
}

#pragma mark -
#pragma mark RootCellDelegate
- (void)rootCell:(RootCell *)cell currentWeatherDataWithShowBlock:(void(^)(CurrentWeatherViewModel *model,BOOL isCache))block
{
    NSInteger index = cell.currentIndex;
    CityModel *city = citys[index];
    if (currentWeatherDict[city.identifier])
    {
        CurrentWeatherViewModel *weather = currentWeatherDict[city.identifier];
        block(weather,YES);
        return;
    }
    
    [cell showLoadingView];
    
    [[WeatherInterface sharedInterface] currentWeatherWithCity:city.name
                                                       success:^(id model) {
                                                           if ([model isKindOfClass:[CurrentWeatherViewModel class]])
                                                           {
                                                               CurrentWeatherViewModel *weather = (CurrentWeatherViewModel *)model;
                                                               [currentWeatherDict setObject:model
                                                                                      forKey:city.identifier];
                                                               // 防止因为重用导致数据不一致
                                                               if (index == cell.currentIndex)
                                                               {
                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                       [cell hideLoadingView];
                                                                       [cell stopRefreshing];
                                                                       block(weather,NO);
                                                                   });
                                                               }
                                                           }
                                                       } failure:^(NSError *error) {
                                                           [self showNetErrorView];
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               [cell hideLoadingView];
                                                               [cell stopRefreshing];
                                                               });
                                                       }];
}

- (void)rootCell:(RootCell *)cell hourlyForecastDataWithShowBlock:(void(^)(NSArray *viewModelArray,BOOL isCache))block
{
    NSInteger index = cell.currentIndex;
    CityModel *city = citys[index];
    if (hourlyForecastDict[city.identifier])
    {
        NSArray *viewModelArray = hourlyForecastDict[city.identifier];
        block(viewModelArray,YES);
        return;
    }
    
    [[WeatherInterface sharedInterface] hourlyforecastWithCity:city.name
                                                     hourCount:8
                                                       success:^(id model) {
                                                           if ([model isKindOfClass:[NSArray class]])
                                                           {
                                                               NSArray *viewModelArray = (NSArray *)model;
                                                               [hourlyForecastDict setObject:viewModelArray forKey:city.identifier];
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
    CityModel *city = citys[index];
    if (dailyForecastDict[city.identifier])
    {
        NSArray *viewModelArray = dailyForecastDict[city.identifier];
        block(viewModelArray,YES);
        return;
    }
    
    [[WeatherInterface sharedInterface] dailyforecastWithCity:city.name
                                                     dayCount:7
                                                      success:^(id model) {
                                                          if ([model isKindOfClass:[NSArray class]])
                                                          {
                                                              NSArray *viewModelArray = (NSArray *)model;
                                                              [dailyForecastDict setObject:viewModelArray forKey:city.identifier];
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
    
    CGFloat translate = MIN(contentOffset.y, 60.0);
    translate = MAX(translate, 0);
    cityListButton.transform = CGAffineTransformMakeTranslation(0, - translate);
    if (bannerView)
    {
        bannerView.transform = CGAffineTransformMakeTranslation(0, translate);
    }
}

- (void)rootCellWeatherTableViewDidTriggerRefreshWithRootCell:(RootCell *)cell
{
    CityModel *city = citys[cell.currentIndex];
    [currentWeatherDict removeObjectForKey:city.identifier];
    [hourlyForecastDict removeObjectForKey:city.identifier];
    [dailyForecastDict removeObjectForKey:city.identifier];
    [cell showWeatherForecastWithIndex:cell.currentIndex city:city.customName isCurrentLocation:city.isCurrentLocation];
}

#pragma mark -
#pragma mark Private Method

- (void)showCityList:(id)sender
{
    CityViewController *cityListVC = [[CityViewController alloc] init];
    cityListVC.delegate = self;
    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:cityListVC];
    [self presentViewController:naviController animated:YES completion:nil];
}

- (void)showNetErrorView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [TSMessage showNotificationWithTitle:@"更新失败"
                                    subtitle:@"请检查网络状况是否畅通"
                                        type:TSMessageNotificationTypeError];
    });
}

#pragma mark -
#pragma mark - CityViewControllerDelegate
- (void)cityViewControllerDidEndEditing
{
    // cities edit finish
    [citys removeAllObjects];
    CityModel *currentLocationCity = [CityListHandler currentLocationCity];
    if (currentLocationCity)
    {
        [citys addObject:currentLocationCity];
    }
    [citys addObjectsFromArray:[CityListHandler cityList]];
    
    [collectionView reloadData];
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
