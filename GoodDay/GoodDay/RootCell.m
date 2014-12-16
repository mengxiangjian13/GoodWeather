//
//  RootCell.m
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/15.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "RootCell.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "SummaryView.h"


@interface RootCell () <UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *blurImageView;
    UITableView *weatherTableView;
    
    // hourly forecast datasource
    NSMutableArray *hourForecastArray;
    // daily forecast datasource
    NSMutableArray *dailyForecastArray;
}

@end

@implementation RootCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // initialize datasource container
        hourForecastArray = [[NSMutableArray alloc] init];
        dailyForecastArray = [[NSMutableArray alloc] init];
        
        // main UI
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundImageView.image = [UIImage imageNamed:@"Images/bg"];
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:backgroundImageView];
        
        blurImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        blurImageView.contentMode = UIViewContentModeScaleAspectFill;
        blurImageView.alpha = 0.0;
        [blurImageView setImageToBlur:[UIImage imageNamed:@"Images/bg"] blurRadius:10.0 completionBlock:nil];
        [self addSubview:blurImageView];
        
        weatherTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        weatherTableView.delegate = self;
        weatherTableView.dataSource = self;
        weatherTableView.backgroundColor = [UIColor clearColor];
        weatherTableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
        weatherTableView.pagingEnabled = YES;
        [self addSubview:weatherTableView];
        
        // show tableHeader
        [self showCurrentWeather];
    }
    return self;
}

- (void)showCurrentWeather
{
    SummaryView *summaryView = [[[NSBundle mainBundle] loadNibNamed:@"SummaryView" owner:self options:nil] lastObject];
    summaryView.frame = self.bounds;
    weatherTableView.tableHeaderView = summaryView;
}

- (void)showWeatherForecastWithIndex:(NSInteger)index city:(NSString *)city
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
            [summaryView showWeatherWithAnimation:!isCache];
        }];
    }
}

- (void)clearView
{
    SummaryView *summaryView = (SummaryView *)weatherTableView.tableHeaderView;
    [summaryView clearView];
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
    return MAX(44, tableView.bounds.size.height / ((CGFloat)[hourForecastArray count]+1));
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = MAX(scrollView.contentOffset.y, 0);
    CGFloat alpha = offset / self.bounds.size.height;
    blurImageView.alpha = MIN(alpha, 1.0);
}

@end