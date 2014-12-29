//
//  RootCell.m
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/15.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "RootCell.h"
#import "SummaryView.h"
#import "LoadingHud.h"
#import <CBStoreHouseRefreshControl/CBStoreHouseRefreshControl.h>


@interface RootCell () <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *weatherTableView;
    
    // hourly forecast datasource
    NSMutableArray *hourForecastArray;
    // daily forecast datasource
    NSMutableArray *dailyForecastArray;
    // loading hud
    LoadingHud *loadingHud;
    // refresh control
    CBStoreHouseRefreshControl *refreshControl;
}

@end

@implementation RootCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        // initialize datasource container
        hourForecastArray = [[NSMutableArray alloc] init];
        dailyForecastArray = [[NSMutableArray alloc] init];
        
        // main UI
        weatherTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        weatherTableView.delegate = self;
        weatherTableView.dataSource = self;
        weatherTableView.backgroundColor = [UIColor clearColor];
        weatherTableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
        weatherTableView.pagingEnabled = YES;
        weatherTableView.alwaysBounceVertical = YES;
        [self addSubview:weatherTableView];
        
        refreshControl = [CBStoreHouseRefreshControl attachToScrollView:weatherTableView
                                                                 target:self
                                                          refreshAction:@selector(refreshTrigger)
                                                                  plist:@"refresh"];
        
        
        // show tableHeader
        [self showCurrentWeather];
    }
    return self;
}

- (void)showCurrentWeather
{
    SummaryView *summaryView = nil;
#if ADBANNER==1
    summaryView = [[[NSBundle mainBundle] loadNibNamed:@"SummaryViewAD" owner:self options:nil] lastObject];
#else
    summaryView = [[[NSBundle mainBundle] loadNibNamed:@"SummaryView" owner:self options:nil] lastObject];
#endif
    summaryView.frame = self.bounds;
    weatherTableView.tableHeaderView = summaryView;
}

- (void)showWeatherForecastWithIndex:(NSInteger)index city:(NSString *)city country:(NSString *)country isCurrentLocation:(BOOL)isCurrentLocation
{
    [self clearView];
    
    self.currentIndex = index;
    SummaryView *summaryView = (SummaryView *)weatherTableView.tableHeaderView;
    summaryView.cityLabel.text = city;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rootCell:currentWeatherDataWithShowBlock:)])
    {
        [self.delegate rootCell:self currentWeatherDataWithShowBlock:^(CurrentWeatherViewModel *weather,BOOL isCache) {
            summaryView.conditionLabel.text = weather.condition;
            summaryView.icon.image = weather.icon;
            summaryView.currentTemperatureLabel.text = weather.currentTemperature;
            summaryView.floatTemperatureLabel.text = weather.floatTemperature;
            summaryView.otherConditionLabel.text = weather.otherCondition;
            if (isCurrentLocation)
            {
                summaryView.isCurrentLocationLabel.text = @"(当前位置)";
            }
            else
            {
                summaryView.isCurrentLocationLabel.text = [NSString stringWithFormat:@"(%@)",country];
            }
            [summaryView showWeatherWithAnimation:!isCache];
        }];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rootCell:hourlyForecastDataWithShowBlock:)])
    {
        [self.delegate rootCell:self hourlyForecastDataWithShowBlock:^(NSArray *viewModelArray, BOOL isCache) {
            if (viewModelArray && [viewModelArray isKindOfClass:[NSArray class]])
            {
                [hourForecastArray removeAllObjects];
                [hourForecastArray addObjectsFromArray:viewModelArray];
                [weatherTableView reloadData];
            }
        }];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rootCell:dailyForecastWeatherDataWithShowBlock:)])
    {
        [self.delegate rootCell:self dailyForecastWeatherDataWithShowBlock:^(NSArray *viewModelArray, BOOL isCache) {
            if (viewModelArray && [viewModelArray isKindOfClass:[NSArray class]])
            {
                [dailyForecastArray removeAllObjects];
                [dailyForecastArray addObjectsFromArray:viewModelArray];
                [weatherTableView reloadData];
            }
        }];
    }
}

- (void)clearView
{
    // clear UI
    SummaryView *summaryView = (SummaryView *)weatherTableView.tableHeaderView;
    [summaryView clearView];
    if (refreshControl.state != CBStoreHouseRefreshControlStateRefreshing)
    {
        weatherTableView.contentOffset = CGPointZero;
    }
    
    [self hideLoadingView];
}

- (void)showLoadingView
{
    loadingHud = [LoadingHud showLoadingHudInView:self];
}

- (void)hideLoadingView
{
    [loadingHud hideLoadingHud];
}

- (void)stopRefreshing
{
    [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:0.5 inModes:@[NSRunLoopCommonModes]];
}

- (void)finishRefreshControl
{
    [refreshControl finishingLoading];
}

#pragma mark -
#pragma mark UITableViewDataSource UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [hourForecastArray count] + 1; // plus 1 because of section header
    }
    
    return [dailyForecastArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.row != 0)
    {
        static NSString *identifier = @"cell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        
        if (indexPath.section == 0)
        {
            HourlyWeatherViewModel *hModel = hourForecastArray[indexPath.row-1];
            cell.imageView.image = hModel.icon;
            cell.detailTextLabel.text = hModel.temperature;
            cell.textLabel.text = hModel.date;
        }
        else
        {
            DailyWeatherViewModel *dModel = dailyForecastArray[indexPath.row-1];
            cell.imageView.image = dModel.icon;
            cell.detailTextLabel.text = dModel.temperature;
            cell.textLabel.text = dModel.date;
        }
        
    }
    else
    {
        static NSString *identifier = @"header";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.row == 0)
    {
        if (indexPath.section == 0)
        {
            cell.textLabel.text = @"24小时预报";
        }
        else
        {
            cell.textLabel.text = @"7天预报";
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    if ([hourForecastArray count] > 0)
    {
        height = MAX(44, tableView.bounds.size.height / ((CGFloat)[hourForecastArray count]+1));
    }
    else if ([dailyForecastArray count] > 0)
    {
        height = MAX(44, tableView.bounds.size.height / ((CGFloat)[dailyForecastArray count]+1));
    }
    return height;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [refreshControl scrollViewDidScroll];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rootCell:weatherTableViewDidScrollWithContentOffset:)])
    {
        [self.delegate rootCell:self weatherTableViewDidScrollWithContentOffset:scrollView.contentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [refreshControl scrollViewDidEndDragging];
}

#pragma mark -
#pragma mark refresh control trigger method
- (void)refreshTrigger
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(rootCellWeatherTableViewDidTriggerRefreshWithRootCell:)])
    {
        [self.delegate rootCellWeatherTableViewDidTriggerRefreshWithRootCell:self];
    }
}

@end
