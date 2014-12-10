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
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    tableView.pagingEnabled = YES;
    [self.view addSubview:tableView];
    
    SummaryView *summaryView = [[[NSBundle mainBundle] loadNibNamed:@"SummaryView" owner:self options:nil] lastObject];
    summaryView.frame = self.view.bounds;
    summaryView.cityLabel.text = @"Beijing";
    tableView.tableHeaderView = summaryView;
    
    __weak SummaryView *weakSummaryView = summaryView;
    [[WeatherInterface sharedInterface] currentWeatherWithCity:@"beijing"
                                                       success:^(id model) {
                                                           if ([model isKindOfClass:[CurrentWeatherModel class]])
                                                           {
                                                               CurrentWeatherModel *weather = (CurrentWeatherModel *)model;
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   weakSummaryView.statusLabel.text = weather.condition;
                                                                   weakSummaryView.icon.image = [UIImage imageNamed:weather.iconImageName];
                                                                   weakSummaryView.currentTemperatureLabel.text = [NSString stringWithFormat:@"%.1f ℃",weather.currentTemperature.floatValue];
                                                                   weakSummaryView.floatTemperatureLabel.text = [NSString stringWithFormat:@"%.1f℃ / %.1f ℃",weather.maxTemperature.floatValue,weather.minTemperature.floatValue];
                                                               });
                                                           }
                                                       } failure:^(NSError *error) {
                                                           [TSMessage showNotificationWithTitle:@"请求失败"
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
