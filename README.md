# libWeatherInfo

This library is designed to allow developers to easily fetch weather information from any process using the users current location or a specified location. iOS 8.0 and up are supported.

## Linking

This can be linked to in a Theos make file by adding:
```
ProjectName_LIBRARIES = WeatherInfo
```

After linking to libProcedural wallpaper, it is important to include the required headers. These include:
```
WBWeatherInfoManager.h
WBCity.h
```
Any required private framework headers can be found in the /include directory.

# Usage:

WBWeatherInfoManager is directly based off of CLLocationManager. If you are familiar with CLLocationManager you are already familiar with WBWeatherInfoManager.
```
#import "WBWeatherInfoManager.h"

@interface MyDelegateClass : NSObject <WBWeatherInfoManagerDelegate>
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) WBWeatherInfoManager *weatherInfoManager;
@end

#import "WBCity.h"

@implementation MyDelegateClass

- (id)init
{
    if (self = [super init]) {
    
        CLLocationDegrees latitude = 51.5072;
        CLLocationDegrees longitude = 0.1275;
        self.location = [[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] autorelease];
        self.weatherInfoManager = [[[WBWeatherInfoManager alloc] initWithDelegate:self] autorelease];
        [self.weatherInfoManager startMonitoringWeatherChangesForLocation:self.location];
        
        // Or update weather based on current location
        // [self.weatherInfoManager startMonitoringCurrentLocationWeatherChanges];
    }
    return self;
}

- (void)weatherInfoManager:(WBWeatherInfoManager *)weatherInfoManager didUpdateWeather:(WBCity *)city
{
    // Use the weather information contained in city
}

- (void)dealloc
{
    [self.weatherInfoManager stopMonitoringWeatherChangesForLocation:self.location];
    //[self.weatherInfoManager stopMonitoringCurrentLocationWeatherChanges];
    [_location release];
    [_weatherInfoManager release];
    [super dealloc];
}

@end
```
