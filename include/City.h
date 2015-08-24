//
//  City.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2014-10-21.
//
//

#import "CityUpdaterDelegate.h"
#import <CoreLocation/CoreLocation.h>

extern NSString *const NilTemperatureString;
extern NSString *const centeredSmallWeatherIcons[];
extern NSString *const WeatherDescription[];

extern NSString *TimeInRegionFormatFromFourDigitTime(NSString *time);
extern NSString *TemperatureInUserUnits(NSString *temperature, BOOL isCelsius);
extern NSString *CondensedTimeInRegionFormat(NSString *time);
extern BOOL IsPrecipitationCondition(int conditionCode);
extern int RemapSmallIconForDayOrNight(int conditionCode, BOOL isDay);
extern int Time24StringToInt(NSString *time);
extern NSString *LocalizedPercentageString(NSString *string);
extern NSString *TemperatureStringWithDegree(NSString *temperature, BOOL isCelsius);

@interface NSString (Weather)
- (NSString *)weatherTemperatureWithDegree;
@end

@interface City : NSObject
@property (nonatomic, setter = setUVIndex:) int uvIndex;
@property (nonatomic) double precipitationPast24Hours;
@property (nonatomic, copy) NSString *deeplink;
@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic) BOOL isLocalWeatherCity;
@property (nonatomic, copy) NSString *woeid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *locationID;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *temperature;
@property (nonatomic) int conditionCode;
@property (nonatomic) int observationTime;
@property (nonatomic) int sunsetTime;
@property (nonatomic) int sunriseTime;
@property (nonatomic) int moonPhase;
@property (nonatomic, copy) NSString *link;
@property (nonatomic) float longitude;
@property (nonatomic) float latitude;
@property (nonatomic) int secondsFromGMT;
@property (nonatomic) BOOL isHourlyDataCelsius;
@property (nonatomic, retain) NSDate *updateTime;
@property (nonatomic, getter = isDataCelsius) BOOL dataCelsius;
@property (nonatomic) float windChill;
@property (nonatomic) float windDirection;
@property (nonatomic) float windSpeed;
@property (nonatomic) float humidity;
@property (nonatomic) float visibility;
@property (nonatomic) float pressure;
@property (nonatomic) int pressureRising;
@property (nonatomic) float dewPoint;
@property (nonatomic) float feelsLike;
@property (nonatomic) float heatIndex;
@property (nonatomic) int lastUpdateStatus;
@property (nonatomic, retain) NSMutableArray *dayForecasts;
@property (nonatomic, retain) NSMutableArray *hourlyForecasts;
- (BOOL)isDay;
- (void)update;
- (NSString *)fullName;
@end
