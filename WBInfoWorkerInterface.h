//
//  WBInfoWorkerInterface.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-07-06.
//
//

@class CLLocation;
@protocol WBInfoWorkerInterface <NSObject>
@required
- (void)startMonitoringCurrentLocationWeatherChanges;
- (void)startMonitoringWeatherChangesForLocation:(CLLocation *)location;
- (void)stopMonitoringCurrentLocationWeatherChanges;
- (void)stopMonitoringWeatherChangesForLocation:(CLLocation *)location;
@end
