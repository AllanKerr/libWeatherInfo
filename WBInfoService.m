//
//  WBInfoService.m
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-07-06.
//
//

#import "WBInfoService.h"
#import "WBInfoWorker.h"
#import "City.h"

@interface WBInfoService ()
@property (nonatomic) BOOL isFirstLocationUpdate;
@property (nonatomic) time_t lastUpdateTime;
@property (nonatomic, assign) NSTimer *updateTimer;
@property (nonatomic, retain) NSMutableArray *locations;
@property (nonatomic, retain) NSMutableArray *currentLocationWorkers;
@property (nonatomic, retain) NSMutableDictionary *locationWorkers;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) WBInfoUpdater *infoUpdater;
@end

@implementation WBInfoService

+ (float)updateInterval
{
    return 1800.0f;
}

+ (float)exitDelay
{
    // delay between the point when the last WBWeatherInfoManager stops updating to when the daemon will stop running
    // by adding a delay weatherinfod will continue running even if SpringBoard crashes allowing connections to be re-established when the process restarts
    return 60.0f;
}

- (id)initWithServiceName:(NSString *)serviceName
{
    if (self = [super init]) {
        self.infoUpdater = [[[WBInfoUpdater alloc] init] autorelease];
        [self.infoUpdater setInfoDelegate:self];
        
        // for updating weather information an accurate location is not necessary
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        self.locationManager.distanceFilter = 3000.0f;
        [self.locationManager setDelegate:self];
        
        self.locations = [NSMutableArray array];
        self.currentLocationWorkers = [NSMutableArray array];
        self.locationWorkers = [NSMutableDictionary dictionary];
        
        self.lastUpdateTime = time(NULL);
    }
    return self;
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)connection
{
    // accepts connections sent from WBWeatherInfoManager
    [[[WBInfoWorker alloc] initWithConnection:connection infoService:self] autorelease];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // if the daemon has initiated its 60 second exit delay it must be canceled because there is now an establish connection
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(exit) object:nil];
    });
    return YES;
}

- (void)systemWillSleep
{
    // halt all updating when the system sleeps
    [self stopUpdateTimer];
}

- (void)systemWillPowerOn
{
    // start updating again now that the system is no longer asleep
    float updateInterval = [WBInfoService updateInterval];
    time_t timeSinceLastUpdate = time(NULL) - self.lastUpdateTime;
    
    if (timeSinceLastUpdate >= updateInterval) {
        // force immediate update because the device was a sleep for longer than the update interval
        [self updateWeatherInfo];
        [self startUpdateTimerIfNeeded];
    } else {
        // the device was not a sleep for longer than the update interval meaning an immediate update is not required
        NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:updateInterval - timeSinceLastUpdate];
        self.updateTimer = [[[NSTimer alloc] initWithFireDate:fireDate interval:updateInterval target:self selector:@selector(updateWeatherInfo) userInfo:nil repeats:YES] autorelease];
        self.updateTimer.tolerance = 0.5f * updateInterval;
        
        [[NSRunLoop currentRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
    }
}


- (void)startUpdateTimerIfNeeded
{
    if (self.updateTimer == nil) {
        float updateInterval = [WBInfoService updateInterval];
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:updateInterval target:self selector:@selector(updateWeatherInfo) userInfo:nil repeats:YES];
        // adding a tolerence allows the system to update at the best interval to preserve battery
        self.updateTimer.tolerance = 0.5f * updateInterval;
    }
}

- (void)stopUpdateTimerIfNeeded
{
    // only stop the timer if there are no WBWeatherInfoManagers recieving updates
    if (self.updateTimer != nil && self.currentLocationWorkers.count == 0 && self.locations.count == 0) {
        [self stopUpdateTimer];
        
        // begin the exit process
        float exitDelay = [WBInfoService exitDelay];
        [self performSelector:@selector(exit) withObject:nil afterDelay:exitDelay];

    }
}

- (void)stopUpdateTimer
{
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

- (NSValue *)_keyForLocation:(CLLocation *)location
{
    // CLLocations do not support -hash or -isEqual
    // to use CLLocations as a dictionary key the longitude and latitude must be converted to a CLLocation
    CLLocationCoordinate2D coordinate = location.coordinate;
    return [NSValue valueWithBytes:&coordinate objCType:@encode(CLLocationCoordinate2D)];
}

- (NSUInteger)_indexForLocation:(CLLocation *)location
{
    // locations within 3 km are treated as being the same location
    return [self.locations indexOfObjectPassingTest:^BOOL(CLLocation *otherLocation, NSUInteger index, BOOL *stop) {
        return [location distanceFromLocation:otherLocation] < 3000.0f;
    }];
}

- (void)registerWorker:(WBInfoWorker *)worker forLocationUpates:(CLLocation *)location
{
    NSUInteger index = [self _indexForLocation:location];
    if (index == NSNotFound) {
        // Register as new location
        NSValue *key = [self _keyForLocation:location];
        NSMutableArray *workers = [NSMutableArray arrayWithObject:worker];
        [self.locationWorkers setObject:workers forKey:key];
        [self.locations addObject:location];
        
    } else {
        // There is a location within 3 km then it is considered the same location
        CLLocation *location = [self.locations objectAtIndex:index];
        NSValue *key = [self _keyForLocation:location];
        NSMutableArray *workers = [self.locationWorkers objectForKey:key];
        
        // Can't register a worker for locaiton updates more than once
        if ([workers containsObject:worker] == NO) {
            [workers addObject:worker];
        }
    }
    // Force weather update when first registering
    [self.infoUpdater performSelectorOnMainThread:@selector(updateWeatherForLocation:) withObject:location waitUntilDone:YES];
    [self startUpdateTimerIfNeeded];
}

- (void)registerWorkerForCurrentLocationUpdates:(WBInfoWorker *)worker
{
    // Can't register a worker for current location updates more than once
    if ([self.currentLocationWorkers containsObject:worker] == NO) {
        [self.currentLocationWorkers addObject:worker];
    }
    // Start or restart location updating to force immediate update
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
    self.isFirstLocationUpdate = YES;

    // Force immediate location update
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startUpdatingLocation];
    [self startUpdateTimerIfNeeded];
}

- (void)unregisterWorker:(WBInfoWorker *)worker forLocationUpates:(CLLocation *)location
{
    NSUInteger index = [self _indexForLocation:location];
    if (index != NSNotFound) {
        // There is a location within 3 km then it is considered the same location
        CLLocation *location = [self.locations objectAtIndex:index];
        NSValue *key = [self _keyForLocation:location];
        NSMutableArray *workers = [self.locationWorkers objectForKey:key];
        if ([workers containsObject:worker]) {
            if (workers.count == 1) {
                // Remove the location completely if there are no more registered workers
                [self.locationWorkers removeObjectForKey:key];
                [self.locations removeObject:location];
            } else {
                [workers removeObject:worker];
            }
        }
    }
    [self stopUpdateTimerIfNeeded];
}

- (void)unregisterWorkerForCurrentLocationUpdates:(WBInfoWorker *)worker
{
    [self.currentLocationWorkers removeObject:worker];

    // Stop updating location if there are no workers registered for current location updates
    if (self.currentLocationWorkers.count == 0) {
        if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
            [self.locationManager stopMonitoringSignificantLocationChanges];
        } else {
            [self.locationManager stopUpdatingLocation];
        }
    }
    [self stopUpdateTimerIfNeeded];
}

- (void)invalidateWorker:(WBInfoWorker *)worker
{
    // Called when the connection between a WBWeatherInfoManager is invalidated
    dispatch_async(dispatch_get_main_queue(), ^{
        // Stop all weather updates for the WBWeatherInfoManager
        [self unregisterWorkerForCurrentLocationUpdates:worker];
        for (int i = self.locations.count - 1; i >= 0; i--) {
            CLLocation *location = [self.locations objectAtIndex:i];
            [self unregisterWorker:worker forLocationUpates:location];
        }
    });
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // Only update the location if the location update was forced
    if (self.isFirstLocationUpdate || ![CLLocationManager significantLocationChangeMonitoringAvailable]) {
        [self.locationManager stopUpdatingLocation];
        self.currentLocation = [locations lastObject];
        
        // WBInfoUpdater is not thread safe
        [self.infoUpdater performSelectorOnMainThread:@selector(updateWeatherForLocation:) withObject:self.currentLocation waitUntilDone:NO];
    }
    self.isFirstLocationUpdate = NO;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.currentLocationWorkers makeObjectsPerformSelector:@selector(didFailWithError:) withObject:error];
}

- (void)infoUpdater:(WBInfoUpdater *)infoUpdater didUpdateCity:(City *)city forLocation:(CLLocation *)location
{
    // when the weather is updated for a location notify all listeners
    WBCity *infoCity = [[[WBCity alloc] initWithCity:city] autorelease];
    NSArray *workers;
    
    // current location weather was updated
    if (self.currentLocation == location) {
        workers = self.currentLocationWorkers;
        self.currentLocation = nil;
    } else {
    // specific location weather was updated
        NSValue *key = [self _keyForLocation:location];
        workers = [self.locationWorkers objectForKey:key];
    }
    [workers makeObjectsPerformSelector:@selector(didUpdateCity:) withObject:infoCity];
}

- (void)infoUpdater:(WBInfoUpdater *)infoUpdater updateFailedForLocation:(CLLocation *)location
{
    NSArray *workers;
    // current location weather update failed
    if (self.currentLocation == location) {
        workers = self.currentLocationWorkers;
        self.currentLocation = nil;
    } else {
    // specific location weather update failed
        NSValue *key = [self _keyForLocation:location];
        workers = [self.locationWorkers objectForKey:key];
    }
    NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil];
    [workers makeObjectsPerformSelector:@selector(didFailWithError:) withObject:error];
}

// updates all weather for all locations recieving updates
- (void)updateWeatherInfo
{
    // remove all pending and currently updating cities
    [self.infoUpdater cleanUp];

    // force a location update if significantLocationChangeMonitoringAvailable isn't available to constantly update in the background
    if ([CLLocationManager significantLocationChangeMonitoringAvailable] == NO) {
        [self.locationManager startUpdatingLocation];
    } else {
        self.currentLocation = [self.locationManager location];
        [self.infoUpdater updateWeatherForLocation:self.currentLocation];
    }
    // update weather for all registered locations
    for (CLLocation *location in self.locations) {
        [self.infoUpdater updateWeatherForLocation:location];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lastUpdateTime = time(NULL);
    });
}

- (void)exit
{
    // stop the run loop allowing main the return
    CFRunLoopStop(CFRunLoopGetMain());
}

- (void)dealloc
{
    [_locations release];
    [_currentLocationWorkers release];
    [_locationWorkers release];
    [_currentLocation release];
    [_locationManager release];
    [_infoUpdater release];
    [super dealloc];
}

@end
