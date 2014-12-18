//
//  FindCityViewController.m
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/17.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "FindCityViewController.h"
#import <UIImageView+LBBlurredImage.h>
#import "WeatherInterface.h"

@interface FindCityViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    NSMutableArray *resultCityArray;
    
    // UISearchBar
    UISearchBar *searchBar;
    
    UITableView *searchTableView;
}
@end

@implementation FindCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    resultCityArray = [[NSMutableArray alloc] init];
    
    searchTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    searchTableView.delegate = self;
    searchTableView.dataSource = self;
    [self.view addSubview:searchTableView];
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
    
    CityModel *model = resultCityArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ , %@",model.customName,model.country];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(findCityViewControllerDidFindCityWithCity:)])
    {
        [self.delegate findCityViewControllerDidFindCityWithCity:[resultCityArray[indexPath.row] customName]];
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
- (void)searchBarTextDidEndEditing:(UISearchBar *)_searchBar
{
    NSLog(@"开始find");
    [[WeatherInterface sharedInterface] findCityWithCityName:_searchBar.text
                                                     success:^(id model) {
                                                         if ([model isKindOfClass:[NSArray class]])
                                                         {
                                                             [resultCityArray removeAllObjects];
                                                             [resultCityArray addObjectsFromArray:model];
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 [searchTableView reloadData];
                                                             });
                                                         }
                                                     } failure:^(NSError *error) {
                                                         ;
                                                     }];
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
