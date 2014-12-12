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
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [TSMessage setDefaultViewController:self];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundImageView.image = [UIImage imageNamed:@"images/bg"];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:backgroundImageView];
    
    blurImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    blurImageView.contentMode = UIViewContentModeScaleAspectFill;
    blurImageView.alpha = 0.0;
    [blurImageView setImageToBlur:[UIImage imageNamed:@"images/bg"] blurRadius:10.0 completionBlock:nil];
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

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
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
