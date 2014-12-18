//
//  CityViewController.m
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/14.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "CityViewController.h"
#import "FindCityViewController.h"

@interface CityViewController () <UITableViewDataSource,UITableViewDelegate,FindCityViewControllerDelegate>
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
}

- (instancetype)initWithCities:(NSArray *)cities
{
    self = [super init];
    if (self)
    {
        allCities = [[NSMutableArray alloc] initWithArray:cities];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
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
        cell.textLabel.text = @"正在定位...";
    }
    else if (indexPath.section == 1)
    {
        cell.textLabel.text = allCities[indexPath.row];
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
    NSString *city = allCities[index];
    [allCities removeObjectAtIndex:index];
    [allCities insertObject:city atIndex:destinationIndexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [allCities removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"当前位置";
    }
    else if (section == 1)
    {
        return @"已选城市";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -

- (void)findCityViewControllerDidFindCityWithCity:(NSString *)city
{
    // cities edit finish
    [allCities addObject:city];
    [listTableView reloadData];
    searchController.searchBar.text = nil;
}

#pragma mark -

- (void)close:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cityViewControllerDidEndEditWithCities:)])
    {
        [self.delegate cityViewControllerDidEndEditWithCities:allCities];
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
