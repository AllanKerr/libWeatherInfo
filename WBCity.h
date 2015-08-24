//
//  WBCity.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-01-23.
//
//

#import "City.h"
#import "HourlyForecast.h"
#import "DayForecast.h"

@interface WBHourlyForecast : HourlyForecast <NSSecureCoding>
/*  return:
        eventType = 0 : localized temperature string in user units
        eventType = 1 : localized "Sunrise" string
        eventType = 2 : localized "Sunset" string
        eventType = 3 : localized "Now" string
 */
- (NSString *)localizedDetail;
//  return: localized time string associated with the forecast
- (NSString *)localizedTime;
//  return: icon associated with the conditionCode and time of day
- (UIImage *)icon;
@end

@interface WBDayForecast : DayForecast <NSSecureCoding>
//  return: localized high temperature string for the day
- (NSString *)localizedHigh;
//  return: localized low temperature string for the day
- (NSString *)localizedLow;
@end

@interface WBCity : City <NSSecureCoding>
@property (nonatomic) BOOL isDay;
- (id)initWithCity:(City *)city;
/*  return: localized description of the current conditionCode
        Mostly Cloudy, Sunny, etc
 */
- (NSString *)shortNaturalLanguageDescription;
//  return : localized current temperature string
- (NSString *)localizedTemperature;
//  return : localized current temperature string with the degree symbol
- (NSString *)localizedTemperatureWithDegree;
//  Localizes the hourly forecast data by adding hourly forecasts for "Now", "Sunrise", and "Sunset". Only necessary when using hourly forecast data
//  Recommended usage in WBWeatherInfoManagerInterface -didUpdateWeather:;
- (void)localize;
@end
