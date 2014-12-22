//
//  LocationHandler.m
//  GoodDay
//
//  Created by Xiangjian Meng on 14/12/22.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "LocationHandler.h"
#import <CoreLocation/CoreLocation.h>
#import "WeatherInterface.h"
#import "CityListHandler.h"

NSString* const LocationHandlerGetCurrentLocationNotification = @"CoreLocationSuccess";
NSString* const LocationHandlerGetLocationFailedNotification = @"CoreLocationFailure";
NSString* const LocationHandlerAuthorizeStatusChangeNotification = @"CoreLocationAuthorizeStatusChange";

@interface LocationHandler () <CLLocationManagerDelegate>
{
    // core location
    CLLocationManager *locationManager;
    
    // flag
    BOOL locationConfirmed;
    
    // authorize status
    CLAuthorizationStatus currentStatus;
}

@end

@implementation LocationHandler
@synthesize locationServiceState;

+ (instancetype)sharedHandler
{
    static id sharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHandler = [[self alloc] init];
    });
    return sharedHandler;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        currentStatus = -1;
        // location manager
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager requestWhenInUseAuthorization];
    }
    return self;
}

- (void)startUpdateLocation
{
    [locationManager startUpdatingLocation];
}

- (LocationServiceState)locationServiceState
{
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    switch (authorizationStatus)
    {
        case kCLAuthorizationStatusNotDetermined:
        {
            return LocationServiceStateNotDetermined;
        }
            break;
        case kCLAuthorizationStatusDenied:
        {
            return LocationServiceStateDenied;
        }
            break;
        case kCLAuthorizationStatusRestricted:
        {
            return LocationServiceStateRestricted;
        }
            break;
            
        default:
            break;
    }
    
    return LocationServiceStateAuthorized;
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"CLAuthorizationStatus : %d",status);
    if (currentStatus != (CLAuthorizationStatus)-1 && currentStatus != status)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:LocationHandlerAuthorizeStatusChangeNotification object:nil];
    }
    currentStatus = status;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"lat:%f,lon:%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
    
    if (!locationConfirmed && CLLocationCoordinate2DIsValid(newLocation.coordinate))
    {
        [manager stopUpdatingLocation];
        locationConfirmed = YES;
        [self findCurrentLocationInfoWithLocation:newLocation];
    }
}

- (void)findCurrentLocationInfoWithLocation:(CLLocation *)location
{
    [[WeatherInterface sharedInterface] findCityWithCityLatitude:location.coordinate.latitude
                                                       longitude:location.coordinate.longitude
                                                         success:^(id model) {
                                                             if ([model isKindOfClass:[NSArray class]])
                                                             {
                                                                 NSArray *modelArray = (NSArray *)model;
                                                                 if ([modelArray count] > 0)
                                                                 {
                                                                     CityModel *currentLocationCity = modelArray[0];
                                                                     currentLocationCity.isCurrentLocation = YES;
                                                                     [CityListHandler setCurrentLocationCity:currentLocationCity];
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         [[NSNotificationCenter defaultCenter] postNotificationName:LocationHandlerGetCurrentLocationNotification object:currentLocationCity];
                                                                     });
                                                                 }
                                                             }
                                                         } failure:^(NSError *error) {
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:LocationHandlerGetLocationFailedNotification object:nil];
                                                             });
                                                         }];
}


@end
