//
//  FindCityViewController.m
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/17.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "FindCityViewController.h"
#import <UIImageView+LBBlurredImage.h>

@interface FindCityViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    NSMutableArray *resultCityArray;
    
    // UISearchBar
    UISearchBar *searchBar;
}
@end

@implementation FindCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    resultCityArray = [[NSMutableArray alloc] initWithObjects:@"beijing",@"tianjin", nil];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [resultCityArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"result";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = resultCityArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(findCityViewControllerDidFindCityWithCity:)])
    {
        [self.delegate findCityViewControllerDidFindCityWithCity:resultCityArray[indexPath.row]];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    if (searchBar == nil || searchBar != searchController.searchBar)
    {
        searchBar = searchController.searchBar;
        searchBar.delegate = self;
    }
}

// searchBar delegate method
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"开始find");
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
