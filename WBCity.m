//
//  WBCity.m
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-01-23.
//
//

#import "WBCity.h"
#import "WeatherIconsUtility.h"
#import "WeatherImageLoader.h"

@interface WBHourlyForecast ()
@property (nonatomic) BOOL isDataCelsius;
@end

@interface WBDayForecast ()
@property (nonatomic) BOOL isDataCelsius;
@end

@interface WBCity ()
+ (NSBundle *)_assetBundle;
@end

@implementation WBHourlyForecast

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithHourlyForecast:(HourlyForecast *)hourlyForecast
{
    if (self = [super init]) {
        self.eventType = hourlyForecast.eventType;
        self.time = hourlyForecast.time;
        self.hourIndex = hourlyForecast.hourIndex;
        self.detail = hourlyForecast.detail;
        self.conditionCode = hourlyForecast.conditionCode;
        self.percentPrecipitation = hourlyForecast.percentPrecipitation;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.eventType = [decoder decodeIntForKey:@"eventType"];
        self.time = [decoder decodeObjectOfClass:[NSString class] forKey:@"time"];
        self.hourIndex = [decoder decodeIntForKey:@"hourIndex"];
        self.detail = [decoder decodeObjectOfClass:[NSString class] forKey:@"detail"];
        self.conditionCode = [decoder decodeIntForKey:@"conditionCode"];
        self.percentPrecipitation = [decoder decodeFloatForKey:@"percentPrecipitation"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt:self.eventType forKey:@"eventType"];
    [encoder encodeObject:self.time forKey:@"time"];
    [encoder encodeInt:self.hourIndex forKey:@"hourIndex"];
    [encoder encodeObject:self.detail forKey:@"detail"];
    [encoder encodeInt:self.conditionCode forKey:@"conditionCode"];
    [encoder encodeFloat:self.percentPrecipitation forKey:@"percentPrecipitation"];
}

- (NSString *)localizedDetail
{
    NSString *localizedDetail;
    // eventType 0 is for temperature hourly forecasts
    if (self.eventType == 0) {
        localizedDetail = TemperatureInUserUnits(self.detail, self.isDataCelsius);
    } else {
        localizedDetail = self.detail;
    }
    return localizedDetail;
}

- (NSString *)localizedTime
{
    return TimeInRegionFormatFromFourDigitTime(self.time);
}

- (UIImage *)icon
{
    NSString *imageName;
    if (self.eventType == 1) {
        imageName = @"centered-sunrise";
    } else if (self.eventType == 2) {
        imageName = @"centered-sunset";
    } else {
        // centeredSmallWeatherIcons is a cache of icon names indexed based on condition code
        imageName = centeredSmallWeatherIcons[self.conditionCode];
    }
    return [WeatherImageLoader conditionImageNamed:imageName];
}

@end

@implementation WBDayForecast

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithDayForecast:(DayForecast *)dayForecast
{
    if (self = [super init]) {
        self.high = dayForecast.high;
        self.low = dayForecast.low;
        self.icon = dayForecast.icon;
        self.dayOfWeek = dayForecast.dayOfWeek;
        self.dayNumber = dayForecast.dayNumber;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.high = [decoder decodeObjectOfClass:[NSString class] forKey:@"high"];
        self.low = [decoder decodeObjectOfClass:[NSString class] forKey:@"low"];
        self.icon = [decoder decodeIntForKey:@"icon"];
        self.dayOfWeek = [decoder decodeIntForKey:@"dayOfWeek"];
        self.dayNumber = [decoder decodeIntForKey:@"dayNumber"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.high forKey:@"high"];
    [encoder encodeObject:self.low forKey:@"low"];
    [encoder encodeInt:self.icon forKey:@"icon"];
    [encoder encodeInt:self.dayOfWeek forKey:@"dayOfWeek"];
    [encoder encodeInt:self.dayNumber forKey:@"dayNumber"];
}

- (NSString *)localizedHigh
{
    return TemperatureInUserUnits(self.high, self.isDataCelsius);
}

- (NSString *)localizedLow
{
    return TemperatureInUserUnits(self.low, self.isDataCelsius);
}

@end

@implementation WBCity

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (NSBundle *)_assetBundle
{
    static dispatch_once_t once;
    static NSBundle *sharedInstance;
    dispatch_once(&once, ^{
        // keep a static cache of the weather framework bundle
        sharedInstance = [[NSBundle bundleWithIdentifier:@"com.apple.weather-framework"] retain];
    });
    return sharedInstance;
}

- (id)initWithCity:(City *)city
{
    if (self = [super init]) {
      
        self.precipitationPast24Hours = city.precipitationPast24Hours;
        self.uvIndex = city.uvIndex;
        self.deeplink = city.deeplink;
        self.fullName = city.fullName;
        self.location = city.location;
        self.isLocalWeatherCity = city.isLocalWeatherCity;
        self.name = city.name;
        self.locationID = city.locationID;
        self.state = city.state;
        self.temperature = city.temperature;
        self.conditionCode = RemapSmallIconForDayOrNight(city.conditionCode, city.isDay);
        self.observationTime = city.observationTime;
        self.sunsetTime = city.sunsetTime;
        self.sunriseTime = city.sunriseTime;
        self.moonPhase = city.moonPhase;
        self.link = city.link;
        self.longitude = city.longitude;
        self.latitude = city.latitude;
        self.secondsFromGMT = city.secondsFromGMT;
        self.isHourlyDataCelsius = city.isHourlyDataCelsius;
        self.updateTime = city.updateTime;
        self.dataCelsius = city.isDataCelsius;
        self.windChill = city.windChill;
        self.windDirection = city.windDirection;
        self.windSpeed = city.windSpeed;
        self.humidity = city.humidity;
        self.visibility = city.visibility;
        self.pressure = city.pressure;
        self.pressureRising = city.pressureRising;
        self.dewPoint = city.dewPoint;
        self.feelsLike = city.feelsLike;
        self.heatIndex = city.heatIndex;
        self.lastUpdateStatus = city.lastUpdateStatus;
        self.isDay = [city isDay];
        
        self.dayForecasts = [NSMutableArray arrayWithCapacity:city.dayForecasts.count];
        for (DayForecast *dayForecast in city.dayForecasts) {
            WBDayForecast *weatherInfoDayForecast = [[WBDayForecast alloc] initWithDayForecast:dayForecast];
            [self.dayForecasts addObject:weatherInfoDayForecast];
            [weatherInfoDayForecast release];
        }
        self.hourlyForecasts = [NSMutableArray arrayWithCapacity:city.hourlyForecasts.count];
        for (HourlyForecast *hourlyForecast in city.hourlyForecasts) {
            WBHourlyForecast *weatherInfoHourlyForecast = [[WBHourlyForecast alloc] initWithHourlyForecast:hourlyForecast];
            [self.hourlyForecasts addObject:weatherInfoHourlyForecast];
            [weatherInfoHourlyForecast release];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.uvIndex = [decoder decodeIntForKey:@"uvIndex"];
        self.precipitationPast24Hours = [decoder decodeDoubleForKey:@"precipitationPast24Hours"];
        self.deeplink = [decoder decodeObjectOfClass:[NSString class] forKey:@"deeplink"];
        self.fullName = [decoder decodeObjectOfClass:[NSString class] forKey:@"fullName"];
        self.location = [decoder decodeObjectOfClass:[CLLocation class] forKey:@"location"];
        self.isLocalWeatherCity = [decoder decodeBoolForKey:@"isLocalWeatherCity"];
        self.name = [decoder decodeObjectOfClass:[NSString class] forKey:@"name"];
        self.locationID = [decoder decodeObjectOfClass:[NSString class] forKey:@"locationID"];
        self.state = [decoder decodeObjectOfClass:[NSString class] forKey:@"state"];
        self.temperature = [decoder decodeObjectOfClass:[NSString class] forKey:@"temperature"];
        self.conditionCode = [decoder decodeIntForKey:@"conditionCode"];
        self.observationTime = [decoder decodeIntForKey:@"observationTime"];
        self.sunsetTime = [decoder decodeIntForKey:@"sunsetTime"];
        self.sunriseTime = [decoder decodeIntForKey:@"sunriseTime"];
        self.moonPhase = [decoder decodeIntForKey:@"moonPhase"];
        self.link = [decoder decodeObjectOfClass:[NSString class] forKey:@"link"];
        self.longitude = [decoder decodeFloatForKey:@"longitude"];
        self.latitude = [decoder decodeFloatForKey:@"latitude"];
        self.secondsFromGMT = [decoder decodeIntForKey:@"secondsFromGMT"];
        self.isHourlyDataCelsius = [decoder decodeBoolForKey:@"isHourlyDataCelsius"];
        self.updateTime = [decoder decodeObjectOfClass:[NSDate class] forKey:@"updateTime"];
        self.dataCelsius = [decoder decodeBoolForKey:@"dataCelsius"];
        self.windChill = [decoder decodeFloatForKey:@"windChill"];
        self.windDirection = [decoder decodeFloatForKey:@"windDirection"];
        self.windSpeed = [decoder decodeFloatForKey:@"windSpeed"];
        self.humidity = [decoder decodeFloatForKey:@"humidity"];
        self.visibility = [decoder decodeFloatForKey:@"visibility"];
        self.pressure = [decoder decodeFloatForKey:@"pressure"];
        self.pressureRising = [decoder decodeIntForKey:@"pressureRising"];
        self.dewPoint = [decoder decodeFloatForKey:@"dewPoint"];
        self.feelsLike = [decoder decodeFloatForKey:@"feelsLike"];
        self.heatIndex = [decoder decodeFloatForKey:@"heatIndex"];
        self.lastUpdateStatus = [decoder decodeIntForKey:@"lastUpdateStatus"];
        self.isDay = [decoder decodeBoolForKey:@"isDay"];
        
        NSSet *dayForecastClasses = [NSSet setWithObjects:[NSMutableArray class], [WBDayForecast class], [NSString class], nil];
        self.dayForecasts = [decoder decodeObjectOfClasses:dayForecastClasses forKey:@"dayForecasts"];

        NSSet *hourlyForecastClasses = [NSSet setWithObjects:[NSMutableArray class], [WBHourlyForecast class], [NSString class], nil];
        self.hourlyForecasts = [decoder decodeObjectOfClasses:hourlyForecastClasses forKey:@"hourlyForecasts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{   
    [encoder encodeInt:self.uvIndex forKey:@"uvIndex"];
    [encoder encodeDouble:self.precipitationPast24Hours forKey:@"precipitationPast24Hours"];
    [encoder encodeObject:self.deeplink forKey:@"deeplink"];
    [encoder encodeObject:self.fullName forKey:@"fullName"];
    [encoder encodeObject:self.location forKey:@"location"];
    [encoder encodeBool:self.isLocalWeatherCity forKey:@"isLocalWeatherCity"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.locationID forKey:@"locationID"];
    [encoder encodeObject:self.state forKey:@"state"];
    [encoder encodeObject:self.temperature forKey:@"temperature"];
    [encoder encodeInt:self.conditionCode forKey:@"conditionCode"];
    [encoder encodeInt:self.observationTime forKey:@"observationTime"];
    [encoder encodeInt:self.sunsetTime forKey:@"sunsetTime"];
    [encoder encodeInt:self.sunriseTime forKey:@"sunriseTime"];
    [encoder encodeInt:self.moonPhase forKey:@"moonPhase"];
    [encoder encodeObject:self.link forKey:@"link"];
    [encoder encodeFloat:self.longitude forKey:@"longitude"];
    [encoder encodeFloat:self.latitude forKey:@"latitude"];
    [encoder encodeInt:self.secondsFromGMT forKey:@"secondsFromGMT"];
    [encoder encodeBool:self.isHourlyDataCelsius forKey:@"isHourlyDataCelsius"];
    [encoder encodeObject:self.updateTime forKey:@"updateTime"];
    [encoder encodeBool:self.isDataCelsius forKey:@"dataCelsius"];
    [encoder encodeFloat:self.windChill forKey:@"windChill"];
    [encoder encodeFloat:self.windDirection forKey:@"windDirection"];
    [encoder encodeFloat:self.windSpeed forKey:@"windSpeed"];
    [encoder encodeFloat:self.humidity forKey:@"humidity"];
    [encoder encodeFloat:self.visibility forKey:@"visibility"];
    [encoder encodeFloat:self.pressure forKey:@"pressure"];
    [encoder encodeInt:self.pressureRising forKey:@"pressureRising"];
    [encoder encodeFloat:self.dewPoint forKey:@"dewPoint"];
    [encoder encodeFloat:self.feelsLike forKey:@"feelsLike"];
    [encoder encodeFloat:self.heatIndex forKey:@"heatIndex"];
    [encoder encodeInt:self.lastUpdateStatus forKey:@"lastUpdateStatus"];
    [encoder encodeBool:self.isDay forKey:@"isDay"];
    [encoder encodeObject:self.dayForecasts forKey:@"dayForecasts"];
    [encoder encodeObject:self.hourlyForecasts forKey:@"hourlyForecasts"];
}

- (WBHourlyForecast *)_nowHourlyForecast
{
    WBHourlyForecast *nowForecast = [[[WBHourlyForecast alloc] init] autorelease];
    nowForecast.time = [[WBCity _assetBundle] localizedStringForKey:@"NOW" value:@"" table:@"WeatherFrameworkLocalizableStrings"];
    nowForecast.isDataCelsius = self.isDataCelsius;
    nowForecast.conditionCode = self.conditionCode;
    nowForecast.detail = self.temperature;
    nowForecast.percentPrecipitation = -1;
    nowForecast.eventType = 3;
    return nowForecast;
}

- (WBHourlyForecast *)_sunsetHourlyForecast
{
    WBHourlyForecast *sunsetHourlyForecast = [[[WBHourlyForecast alloc] init] autorelease];
    sunsetHourlyForecast.time = [NSString stringWithFormat:@"%04i", self.sunsetTime];
    sunsetHourlyForecast.detail = [[WBCity _assetBundle] localizedStringForKey:@"SUNSET_COMPACT" value:@"" table:@"WeatherFrameworkLocalizableStrings"];
    sunsetHourlyForecast.isDataCelsius = self.isDataCelsius;
    sunsetHourlyForecast.eventType = 2;
    return sunsetHourlyForecast;
}

- (WBHourlyForecast *)_sunriseHourlyForecast
{
    WBHourlyForecast *sunriseHourlyForecast = [[[WBHourlyForecast alloc] init] autorelease];
    sunriseHourlyForecast.time = [NSString stringWithFormat:@"%04i", self.sunriseTime];
    sunriseHourlyForecast.detail = [[WBCity _assetBundle] localizedStringForKey:@"SUNRISE_COMPACT" value:@"" table:@"WeatherFrameworkLocalizableStrings"];
    sunriseHourlyForecast.isDataCelsius = self.isDataCelsius;
    sunriseHourlyForecast.eventType = 1;
    return sunriseHourlyForecast;
}

- (NSString *)shortNaturalLanguageDescription
{
    NSString * shortDescriptionKey;
    // WeatherIconsUtility was added in iOS 8.2
    Class weatherIconsUtilityClass = NSClassFromString(@"WeatherIconsUtility");
    if (weatherIconsUtilityClass) {
        shortDescriptionKey = [weatherIconsUtilityClass lookupWeatherDescription:self.conditionCode];
    } else {
        // WeatherDescription is a cache of localization keys indexed based on condition code
        shortDescriptionKey = WeatherDescription[self.conditionCode];
    }
    return  [[WBCity _assetBundle] localizedStringForKey:shortDescriptionKey value:@"" table:@"WeatherFrameworkLocalizableStrings"];
}

- (NSString *)localizedTemperature
{
    return TemperatureInUserUnits(self.temperature, self.isDataCelsius);
}

- (NSString *)localizedTemperatureWithDegree
{
    return [TemperatureInUserUnits(self.temperature, self.isDataCelsius) weatherTemperatureWithDegree];
}

- (void)localize
{
    NSMutableArray *mutableHourlyForecasts = [NSMutableArray arrayWithCapacity:self.hourlyForecasts.count + 3];
    for (WBDayForecast *dayForecast in self.dayForecasts) {
        dayForecast.isDataCelsius = self.isDataCelsius;
    }
    // Add "Now" hourly forecast
    if (self.conditionCode != 3200 && [self.temperature isEqualToString:NilTemperatureString] == NO) {
        WBHourlyForecast *nowForecast = [self _nowHourlyForecast];
        [mutableHourlyForecasts addObject:nowForecast];
        
        // Add sunset forecast if it is in less than an hour
        if (self.isDay && abs(self.sunsetTime - self.observationTime) < 100) {
            WBHourlyForecast *sunsetHourlyForecast = [self _sunsetHourlyForecast];
            [mutableHourlyForecasts addObject:sunsetHourlyForecast];
        // Add sunrise forecast if it is in less than an hour
        } else if (!self.isDay && abs( self.sunriseTime - self.observationTime) < 100) {
            WBHourlyForecast *sunriseHourlyForecast = [self _sunriseHourlyForecast];
            [mutableHourlyForecasts addObject:sunriseHourlyForecast];
        }
    }
    for (WBHourlyForecast *hourlyForecast in self.hourlyForecasts) {
        
        BOOL isDay;
        // deterime whether the conditionCode is during the day or night
        int hour = Time24StringToInt(hourlyForecast.time);
        if (self.sunriseTime > self.sunsetTime) {
            isDay = hour > self.sunriseTime || hour < self.sunsetTime;
        } else {
            isDay = hour > self.sunriseTime && hour < self.sunsetTime;
        }
        // remap the conidition code based on the time of day
        hourlyForecast.conditionCode = RemapSmallIconForDayOrNight(hourlyForecast.conditionCode, isDay);
        hourlyForecast.isDataCelsius = self.isDataCelsius;
        [mutableHourlyForecasts addObject:hourlyForecast];
        
        // Add sunset forecast if it is in less than an hour
        if (self.sunsetTime > hour && self.sunsetTime < 100 + hour) {
            WBHourlyForecast *sunsetHourlyForecast = [self _sunsetHourlyForecast];
            [mutableHourlyForecasts addObject:sunsetHourlyForecast];
        // Add sunrise forecast if it is in less than an hour
        } else if (self.sunriseTime > hour && self.sunriseTime < 100 + hour) {
            WBHourlyForecast *sunriseHourlyForecast = [self _sunriseHourlyForecast];
            [mutableHourlyForecasts addObject:sunriseHourlyForecast];
        }
    }
    self.hourlyForecasts = mutableHourlyForecasts;
}

@end
