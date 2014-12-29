//
//  CityViewController.m
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/14.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "CityViewController.h"
#import "FindCityViewController.h"
#import "CityListHandler.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationHandler.h"
#import "CitySettingViewController.h"

@interface CityViewController () <UITableViewDataSource,UITableViewDelegate,FindCityViewControllerDelegate,CLLocationManagerDelegate>
{
    NSMutableArray *allCities;
    // main tableView
    UITableView *listTableView;
    
    //searchVC;
    UISearchController *searchController;
}

@end

@implementation CityViewController

- (void)dealloc
{
    searchController.searchResultsUpdater = nil;
    searchController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    allCities = [CityListHandler mutableCityList];
    
    // navigationItem
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                style:UIBarButtonItemStylePlain
                                               target:self
                                               action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                               target:self
                                                                               action:@selector(editCityList:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    // tableView
    listTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    listTableView.delegate = self;
    listTableView.dataSource = self;
    [self.view addSubview:listTableView];
    
    FindCityViewController *findVC = [FindCityViewController new];
    findVC.delegate = self;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        searchController = [[UISearchController alloc] initWithSearchResultsController:findVC];
        searchController.searchResultsUpdater = findVC;
        [searchController.searchBar sizeToFit];
        listTableView.tableHeaderView = searchController.searchBar;
        searchController.searchBar.placeholder = @"查找并添加新城市";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:LocationHandlerGetCurrentLocationNotification object:nil];
}

- (NSString *)firstRowText
{
    LocationServiceState state = [LocationHandler sharedHandler].locationServiceState;
    switch (state)
    {
        case LocationServiceStateDenied:
        {
            return @"定位服务已关闭";
        }
            break;
        case LocationServiceStateRestricted:
        {
            return @"定位服务受限";
        }
            break;
        default:
        {
            CityModel *currentLocationCity = [CityListHandler currentLocationCity];
            if (currentLocationCity)
            {
                return currentLocationCity.customName;
            }
            return @"正在定位...";
        }
            break;
    }
    
    return @"正在定位...";
}

- (void)reloadTableView
{
    if (listTableView)
    {
        [listTableView reloadData];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
    {
        return [allCities count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0)
    {
        cell.textLabel.text = [self firstRowText];
    }
    else if (indexPath.section == 1)
    {
        CityModel *city = allCities[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",city.customName,city.country];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        return YES;
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSInteger index = sourceIndexPath.row;
    CityModel *city = allCities[index];
    [allCities removeObjectAtIndex:index];
    [allCities insertObject:city atIndex:destinationIndexPath.row];
    
    [CityListHandler synchronize];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [allCities removeObjectAtIndex:indexPath.row];
        if ([allCities count] == 0)
        {
            [tableView reloadData];
        }
        else
        {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [CityListHandler synchronize];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"当前位置";
    }
    else if (section == 1 && [allCities count] > 0)
    {
        return @"已选城市";
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 1 && [allCities count] > 0)
    {
        return @"通过右上角的编辑按钮，可以对已选城市进行排序，还可以删除你不再想关注的城市。";
    }
    else if (section == 0)
    {
        if ([[LocationHandler sharedHandler] locationServiceState] == LocationServiceStateDenied ||
            [[LocationHandler sharedHandler] locationServiceState] == LocationServiceStateRestricted)
        {
            return @"请确认您在系统设置->隐私->定位服务中已经开启了本app的定位服务，好天儿才能帮您找到您当前位置的天气信息。";
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        CityModel *city = allCities[indexPath.row];
        CitySettingViewController *settingVC = [[CitySettingViewController alloc] initWithCity:city];
        [self.navigationController pushViewController:settingVC animated:YES];
    }
}

#pragma mark -

- (void)findCityViewControllerDidFindCityWithCity:(CityModel *)city
{
    // find city finished
    [allCities addObject:city];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[allCities count] - 1 inSection:1];
    [listTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    searchController.searchBar.text = nil;
    
    [CityListHandler synchronize];
}

#pragma mark -

- (void)close:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cityViewControllerDidEndEditing)])
    {
        [self.delegate cityViewControllerDidEndEditing];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)editCityList:(id)sender
{
    [listTableView setEditing:!listTableView.editing animated:YES];
    UIBarButtonItem *item = nil;
    if (listTableView.editing)
    {
        item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editCityList:)];
    }
    else
    {
        item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editCityList:)];
    }
    self.navigationItem.rightBarButtonItem = item;
}

@end
