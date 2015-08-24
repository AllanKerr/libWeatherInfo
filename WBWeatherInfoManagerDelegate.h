//
//  WBWeatherInfoManagerDelegate.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-07-06.
//
//

#import "WBCity.h"

@class WBWeatherInfoManager;
@protocol WBWeatherInfoManagerDelegate <NSObject>
@optional
- (void)weatherInfoManager:(WBWeatherInfoManager *)weatherInfoManager didUpdateWeather:(WBCity *)city;
- (void)weatherInfoManager:(WBWeatherInfoManager *)weatherInfoManager didFailWithError:(NSError *)error;
@end
