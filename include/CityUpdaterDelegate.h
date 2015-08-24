//
//  CityUpdaterDelegate.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2014-10-21.
//
//

@class City;
@protocol CityUpdaterDelegate
- (void)cityDidStartWeatherUpdate:(City *)city;
- (void)cityDidFinishWeatherUpdate:(City *)city;
@end
