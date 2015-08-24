//
//  WBInfoUpdaterDelegate.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-07-07.
//
//

#import <CoreLocation/CoreLocation.h>

@class WBInfoUpdater;
@protocol WBInfoUpdaterDelegate <NSObject>
@optional
- (void)infoUpdater:(WBInfoUpdater *)infoUpdater didUpdateCity:(City *)city forLocation:(CLLocation *)location;
- (void)infoUpdater:(WBInfoUpdater *)infoUpdater updateFailedForLocation:(CLLocation *)location;
@end
