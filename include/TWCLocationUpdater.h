//
//  TWCLocationUpdater.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-07-06.
//
//

#import "TWCUpdater.h"

@interface TWCLocationUpdater : TWCUpdater 
    
+ (void)clearSharedLocationUpdater;
+ (id)sharedLocationUpdater;

- (void)_failed:(unsigned int)arg1;
- (void)_geocodeLocation:(id)arg1;
- (id)aggregateDictionaryDomain;
- (void)cancel;
- (id)currentCity;
- (void)dealloc;
- (void)didProcessJSONObject;
- (void)enableProgressIndicator:(BOOL)arg1;
- (void)failCity:(id)arg1;
- (void)handleCompletionForCity:(id)arg1 withUpdateDetail:(unsigned int)arg2;
- (void)handleNilCity;
- (id)init;
- (void)parsedResultCity:(id)arg1;
- (void)setCurrentCity:(id)arg1;
- (void)updateWeatherForLocation:(id)arg1 city:(id)arg2;
- (void)updateWeatherForLocation:(id)arg1 city:(id)arg2 withCompletionHandler:(id /* block */)arg3;

@end
