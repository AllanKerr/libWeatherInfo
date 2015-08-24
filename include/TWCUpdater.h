//
//  TWCUpdater.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-07-06.
//
//

#import "WeatherJSONHTTPRequest.h"
#import "City.h"

@interface TWCUpdater : WeatherJSONHTTPRequest
{
    NSMutableArray *_updatingCities;
    NSMutableArray *_pendingCities;
}
- (void)addCityToPendingQueue:(City *)city;
@end