//
//  WBInfoUpdater.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-07-07.
//
//

#import "TWCCityUpdater.h"
#import "WBInfoUpdaterDelegate.h"

@interface WBInfoUpdater : TWCCityUpdater
@property (nonatomic, assign) id <WBInfoUpdaterDelegate> infoDelegate;
// Call to update the weather the specified location (which may take several seconds) and notify your delegate by calling its infoUpdater:didUpdateCity: forLocation: This method must be called on the thread the instance was created on
- (void)updateWeatherForLocation:(CLLocation *)location;
// forcibly remove all updating and pending update cities
- (void)cleanUp;
@end
