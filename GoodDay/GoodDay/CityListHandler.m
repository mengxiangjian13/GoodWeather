//
//  CityListHandler.m
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/19.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "CityListHandler.h"
#define PlistFileName @"city.plist"


@interface NSMutableDictionary (NoneNil)

- (void)setNoneNilObject:(id)anObject forKey:(id<NSCopying>)aKey;

@end

@implementation NSMutableDictionary (NoneNil)

- (void)setNoneNilObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (anObject)
    {
        [self setObject:anObject forKey:aKey];
    }
}

@end


static NSMutableArray *cityList = nil;
static NSString *saveFilePath = @"";

@implementation CityListHandler

+ (void)initialize
{
    if (cityList == nil)
    {
        NSMutableArray *mutableCityList = [[NSMutableArray alloc] init];
        NSArray *modelList = [self cityModelArrayWithPlistFilePath:[self saveFilePath]];
        if ([modelList isKindOfClass:[NSArray class]])
        {
            [mutableCityList addObjectsFromArray:modelList];
        }
        cityList = mutableCityList;
    }
}

+ (NSArray *)cityModelArrayWithPlistFilePath:(NSString *)filePath
{
    if (filePath)
    {
        NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
        if (array)
        {
            NSMutableArray *modelList = [[NSMutableArray alloc] init];
            for (int i = 0; i < [array count]; i++)
            {
                id object = array[i];
                if ([object isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary *dict = (NSDictionary *)object;
                    CityModel *city = [self cityModelWithDictionary:dict];
                    [modelList addObject:city];
                }
            }
            return modelList;
        }
    }
    
    return nil;
}

+ (CityModel *)cityModelWithName:(NSString *)name
                      customName:(NSString *)customName
                             lat:(NSNumber *)lat
                             lon:(NSNumber *)lon
                      identifier:(NSString *)identifier
                         country:(NSString *)country
{
    CityModel *model = [[CityModel alloc] init];
    model.name = name;
    model.customName = customName;
    model.lat = lat;
    model.lon = lon;
    model.identifier = identifier;
    model.country = country;
    return model;
}

+ (NSMutableArray *)mutableCityList
{
    return cityList;
}

+ (NSArray *)cityList
{
    return [self mutableCityList];
}

+ (void)addCity:(CityModel *)city
{
    if (city)
    {
        [cityList addObject:city];
    }
}

+ (void)insertCity:(CityModel *)city atIndex:(NSInteger)index
{
    if (city)
    {
        [cityList insertObject:city atIndex:index];
    }
}

+ (void)deleteCityAtIndex:(NSInteger)index
{
    if (index >= 0 && index < [cityList count])
    {
        [cityList removeObjectAtIndex:index];
    }
}

+ (void)exchangeCityAtIndex:(NSInteger)fromIndex withCityAtIndex:(NSInteger)toIndex
{
    if (fromIndex >= 0 && fromIndex < [cityList count] && toIndex >= 0 && toIndex < [cityList count])
    {
        [cityList exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    }
}

+ (NSInteger)cityListCount
{
    return [cityList count];
}

+ (BOOL)synchronize
{
    // synchronize citylist into sandbox file system
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (CityModel *model in cityList)
    {
        NSDictionary *dict = [self dictionaryWithCityModel:model];
        [array addObject:dict];
    }
    
    return [array writeToFile:[self saveFilePath] atomically:YES];
}

#pragma mark -
+ (NSString *)saveFilePath
{
    if (saveFilePath.length == 0)
    {
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        saveFilePath = [libraryPath stringByAppendingFormat:@"/%@",PlistFileName];
    }
    return saveFilePath;
}

+ (NSDictionary *)dictionaryWithCityModel:(CityModel *)city
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setNoneNilObject:city.name forKey:@"name"];
    [dict setNoneNilObject:city.customName forKey:@"customName"];
    [dict setNoneNilObject:city.lat forKey:@"lat"];
    [dict setNoneNilObject:city.lon forKey:@"lon"];
    [dict setNoneNilObject:city.country forKey:@"country"];
    [dict setNoneNilObject:city.identifier forKey:@"identifier"];
    [dict setNoneNilObject:city.backgroundImageName forKey:@"backgroundImageName"];
    return dict;
}

+ (CityModel *)cityModelWithDictionary:(NSDictionary *)dict
{
    CityModel *cityModel = [[CityModel alloc] init];
    cityModel.name = dict[@"name"];
    cityModel.customName = dict[@"customName"];
    cityModel.lat = dict[@"lat"];
    cityModel.lon = dict[@"lon"];
    cityModel.country = dict[@"country"];
    cityModel.identifier = dict[@"identifier"];
    cityModel.backgroundImageName = dict[@"backgroundImageName"];
    return cityModel;
}

@end
