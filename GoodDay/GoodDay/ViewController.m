//
//  ViewController.m
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/9.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "ViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import <TSMessages/TSMessage.h>
#import "SummaryView.h"
#import "WeatherInterface.h"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *blurImageView;
    UITableView *weatherTableView;
    
    // hourly forecast datasource
    NSMutableArray *hourForecastArray;
    // daily forecast datasource
    NSMutableArray *dailyForecastArray;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // set TSMessage default viewcontroller
    [TSMessage setDefaultViewController:self];
    
    // initialize datasource container
    hourForecastArray = [[NSMutableArray alloc] init];
    dailyForecastArray = [[NSMutableArray alloc] init];
    
    // main UI
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundImageView.image = [UIImage imageNamed:@"Images/bg"];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:backgroundImageView];
    
    blurImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    blurImageView.contentMode = UIViewContentModeScaleAspectFill;
    blurImageView.alpha = 0.0;
    [blurImageView setImageToBlur:[UIImage imageNamed:@"Images/bg"] blurRadius:10.0 completionBlock:nil];
    [self.view addSubview:blurImageView];
    
    weatherTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    weatherTableView.delegate = self;
    weatherTableView.dataSource = self;
    weatherTableView.backgroundColor = [UIColor clearColor];
    weatherTableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    weatherTableView.pagingEnabled = YES;
    [self.view addSubview:weatherTableView];
    
    // show tableHeader
    [self showCurrentWeather];
    
    // hourly forecast data
    [self showHourlyForecast];
}

- (void)showCurrentWeather
{
    SummaryView *summaryView = [[[NSBundle mainBundle] loadNibNamed:@"SummaryView" owner:self options:nil] lastObject];
    summaryView.frame = self.view.bounds;
    summaryView.cityLabel.text = @"Beijing";
    weatherTableView.tableHeaderView = summaryView;
    
    __weak SummaryView *weakSummaryView = summaryView;
    [[WeatherInterface sharedInterface] currentWeatherWithCity:@"beijing"
                                                       success:^(id model) {
                                                           if ([model isKindOfClass:[CurrentWeatherViewModel class]])
                                                           {
                                                               CurrentWeatherViewModel *weather = (CurrentWeatherViewModel *)model;
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   weakSummaryView.conditionLabel.text = weather.condition;
                                                                   weakSummaryView.icon.image = weather.icon;
                                                                   weakSummaryView.currentTemperatureLabel.text = weather.currentTemperature;
                                                                   weakSummaryView.floatTemperatureLabel.text = weather.floatTemperature;
                                                                   weakSummaryView.otherConditionLabel.text = weather.otherCondition;
                                                                   [weakSummaryView showWeatherWithAnimation:YES];
                                                               });
                                                           }
                                                       } failure:^(NSError *error) {
                                                           [TSMessage showNotificationWithTitle:@"更新失败"
                                                                                       subtitle:@"请检查网络状况是否畅通"
                                                                                           type:TSMessageNotificationTypeError];
                                                       }];
}

- (void)showHourlyForecast
{
    [[WeatherInterface sharedInterface] hourlyforecastWithCity:@"beijing"
                                                       success:^(id model) {
                                                           if ([model isKindOfClass:[NSArray class]])
                                                           {
                                                               [hourForecastArray addObjectsFromArray:model];
                                                               [weatherTableView reloadData];
                                                           }
                                                       } failure:^(NSError *error) {
                                                           [TSMessage showNotificationWithTitle:@"更新失败"
                                                                                       subtitle:@"请检查网络状况是否畅通"
                                                                                           type:TSMessageNotificationTypeError];
                                                       }];
}

#pragma mark -
#pragma mark UITableViewDataSource

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
        
        HourlyWeatherViewModel *hModel = hourForecastArray[indexPath.row-1];
        
        cell.imageView.image = hModel.icon;
        cell.detailTextLabel.text = hModel.temperature;
        cell.textLabel.text = hModel.date;
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

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = MAX(scrollView.contentOffset.y, 0);
    CGFloat alpha = offset / self.view.bounds.size.height;
    blurImageView.alpha = MIN(alpha, 1.0);
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
