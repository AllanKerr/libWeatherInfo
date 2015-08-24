//
//  WBInfoUpdater.m
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-07-07.
//
//

#import "WBInfoUpdater.h"
#import "City.h"

@implementation WBInfoUpdater

- (void)cleanUp
{
    [_updatingCities removeAllObjects];
    [_pendingCities removeAllObjects];
    [self cancel];
}

- (void)updateWeatherForLocation:(CLLocation *)location
{
    if (location != nil) {
        City *city = [[[City alloc] init] autorelease];
        [city setLocation:location];
        
        // Adds the city to the waiting queue if there is a city currently updating
        if (_updatingCities.count > 0) {
            [self addCityToPendingQueue:city];
        } else {
            [self updateWeatherForCity:city];
        }
    }
}

- (void)_updateNextPendingCity
{
    // Update the next pending city and remove from the queue
    City *city = [_pendingCities firstObject];
    if (city != nil) {
        [self updateWeatherForCity:city];
        [_pendingCities removeObjectAtIndex:0];
    }
}

- (void)parsedResultCity:(City *)city
{
    if ([self.infoDelegate respondsToSelector:@selector(infoUpdater: didUpdateCity: forLocation:)]) {
        
        // -updateWeatherForCity does not provide a locationID
        // locationID is needed for reverse geocoding the name of a location
        CLLocationCoordinate2D coordinate = city.location.coordinate;
        if (city.locationID == nil) {
            city.locationID = [NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
        }
        [self.infoDelegate infoUpdater:self didUpdateCity:city forLocation:city.location];
    }
}

- (void)failCity:(City *)city
{
    if ([self.infoDelegate respondsToSelector:@selector(infoUpdater: updateFailedForLocation:)]) {
        [self.infoDelegate infoUpdater:self updateFailedForLocation:city.location];
    }
}

@end
