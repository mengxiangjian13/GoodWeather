//
//  CitySettingViewController.m
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/29.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "CitySettingViewController.h"

@interface CitySettingViewController () <UITableViewDataSource,UITableViewDelegate>
{
    CityModel *currentCity;
}

@end

@implementation CitySettingViewController

- (instancetype)initWithCity:(CityModel *)city
{
    self = [super init];
    if (self)
    {
        currentCity = city;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = currentCity.customName;
    
    // tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

#pragma mark -
#pragma mark <UITableViewDataSource,UITableViewDelegate>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
    }
    
    if (indexPath.section == 0)
    {
        cell.textLabel.text = currentCity.customName;
    }
    else
    {
        cell.textLabel.text = currentCity.backgroundImageName ? currentCity.backgroundImageName : @"默认图片";
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"自定义名称";
    }
    
    return @"背景图片";
}

@end
