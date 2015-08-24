//
//  TWCCityUpdater.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-07-07.
//
//

#import "TWCUpdater.h"

@interface TWCCityUpdater : TWCUpdater
- (void)updateWeatherForCity:(City *)city;
@end
