//
//  WBWeatherInfoManagerInterface.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-07-06.
//
//

#import "WBCity.h"

@protocol WBWeatherInfoManagerInterface <NSObject>
@required
- (void)didUpdateWeather:(WBCity *)city;
- (void)didFailWithError:(NSError *)error;
@end
