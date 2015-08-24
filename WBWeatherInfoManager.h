//
//  WBWeatherInfoManager.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-07-06.
//
//

#import "WBWeatherInfoManagerDelegate.h"

@class CLLocation;
@interface WBWeatherInfoManager : NSObject
@property (nonatomic, assign) id <WBWeatherInfoManagerDelegate>delegate;
@property (readonly, nonatomic) BOOL isMonitoringCurrentLocationWeatherChanges;
- (id)initWithDelegate:(id <WBWeatherInfoManagerDelegate>)delegate;
- (BOOL)isMonitoringWeatherChangesForLocation:(CLLocation *)location;

// Calling -startMonitoringCurrentLocationWeatherChanges or -startMonitoringWeatherChangesForLocation causes the weather info manager to obtain initial weather data (which may take several seconds) and notify your delegate by calling its weatherInfoManager:didUpdateWeather: method. After that, the receiver generates updates every 30 minutes. If the device recieves kIOMessageSystemWillSleep updates will halt until kIOMessageSystemWillPowerOn. If the device has been asleep for greater than 30 minutes an update will occur immediately upon waking.
//Calling this method several times in succession does not automatically result in new events being generated. Calling stopMonitoringCurrentLocationWeatherChanges or -stopMonitoringWeatherChangesForLocation in between, however, does cause a new initial event to be sent the next time you call this method.

- (void)startMonitoringCurrentLocationWeatherChanges;
- (void)startMonitoringWeatherChangesForLocation:(CLLocation *)location;
- (void)stopMonitoringCurrentLocationWeatherChanges;
- (void)stopMonitoringWeatherChangesForLocation:(CLLocation *)location;
@end
