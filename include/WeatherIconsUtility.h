//
//  WeatherIconsUtility.h
//  WeatherLock
//
//  Created by Allan Kerr on 2015-08-08.
//
//

@interface WeatherIconsUtility : NSObject
+ (NSString *)lookupWeatherDescriptionShort:(int)conditionCode;
+ (NSString *)lookupWeatherDescription:(int)conditionCode;
@end
