//
//  WBWeatherInfoManager.m
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-07-06.
//
//

#import "WBWeatherInfoManager.h"
#import "WBWeatherInfoManagerInterface.h"
#import "WBInfoWorkerInterface.h"
#import "NSXPCConnection.h"
#import <CoreLocation/CoreLocation.h>

@interface WBWeatherInfoManager ()
@property (readwrite, nonatomic) BOOL isMonitoringCurrentLocationWeatherChanges;
@property (nonatomic, retain) NSMutableArray *monitoredLocations;
@property (nonatomic, retain) id remoteObject;
@property (nonatomic, retain) NSXPCConnection *connection;
@end

@implementation WBWeatherInfoManager

- (id)initWithDelegate:(id <WBWeatherInfoManagerDelegate>)delegate
{
    if (self = [super init]) {

        self.monitoredLocations = [NSMutableArray array];
        self.delegate = delegate;

        // Defines the interface between WBWeatherInfoManager and weatherinfod
        NSSet *classes = [NSSet setWithObjects:[CLLocation class], nil];
        NSXPCInterface *serverInterface = [NSXPCInterface interfaceWithProtocol:@protocol(WBInfoWorkerInterface)];
        NSXPCInterface *clientInterface = [NSXPCInterface interfaceWithProtocol:@protocol(WBWeatherInfoManagerInterface)];
        [serverInterface setClasses:classes forSelector:@selector(startMonitoringWeatherChangesForLocation:) argumentIndex:0 ofReply:NO];
        [serverInterface setClasses:classes forSelector:@selector(stopMonitoringWeatherChangesForLocation:) argumentIndex:0 ofReply:NO];
        
        // Creates the xpc connection the weatherinfod
        self.connection = [[[NSXPCConnection alloc] initWithMachServiceName:@"com.theronen.weatherinfod" options:NSXPCConnectionPrivileged] autorelease];
        [self.connection setRemoteObjectInterface:serverInterface];
        [self.connection setExportedInterface:clientInterface];
        [self.connection resume];
    }
    return self;
}

- (void)_startConnectionIfNeeded
{
    // Only start the connection if there isn't a valid remoteObject
    if (self.remoteObject == nil) {
        self.connection.interruptionHandler = ^(){
            // If the daemon crashes re-establish the connection
            [self _reestablishConnection];
        };
        self.remoteObject = [self.connection remoteObjectProxyWithErrorHandler:^(NSError *error) {
            if ([self.delegate respondsToSelector:@selector(weatherInfoManager: didFailWithError:)]) {
                [self.delegate weatherInfoManager:self didFailWithError:error];
            }
        }];
        [self.connection setExportedObject:self];
    }
}

- (void)_stopConnectionIfNeeded
{
    // Stop the connection if no locations are being monitored
    if (self.isMonitoringCurrentLocationWeatherChanges == NO && self.monitoredLocations.count == 0) {
        [self.connection setExportedObject:nil];
        self.connection.interruptionHandler = nil;
        self.remoteObject = nil;
    }
}

- (void)_reestablishConnection
{
    // Start updates for all monitored locations and the current location if necessary
    NSMutableArray *monitoredLocationsCopy = [self.monitoredLocations mutableCopy];
    BOOL isMonitoringCurrentLocationWeatherChangesCopy = self.isMonitoringCurrentLocationWeatherChanges;
    self.isMonitoringCurrentLocationWeatherChanges = NO;
    [self.monitoredLocations removeAllObjects];
    
    if (isMonitoringCurrentLocationWeatherChangesCopy) {
        [self startMonitoringCurrentLocationWeatherChanges];
    }
    for (CLLocation *location in monitoredLocationsCopy) {
        [self startMonitoringWeatherChangesForLocation:location];
    }
}

- (NSUInteger)_indexForLocation:(CLLocation *)location
{
    // Locations within 3 km of eachother are treated as the same location
    return [self.monitoredLocations indexOfObjectPassingTest:^BOOL(CLLocation *otherLocation, NSUInteger index, BOOL *stop) {
        return [location distanceFromLocation:otherLocation] < 3000.0f;
    }];
}

- (BOOL)isMonitoringWeatherChangesForLocation:(CLLocation *)location
{
    return [self _indexForLocation:location] != NSNotFound;
}

- (void)startMonitoringCurrentLocationWeatherChanges
{
    if (self.isMonitoringCurrentLocationWeatherChanges == NO) {
        [self _startConnectionIfNeeded];
        // Send -startMonitoringCurrentLocationWeatherChanges to weatherinfod
        [self.remoteObject startMonitoringCurrentLocationWeatherChanges];
        self.isMonitoringCurrentLocationWeatherChanges = YES;
    }
}

- (void)startMonitoringWeatherChangesForLocation:(CLLocation *)location
{
    // Prevent duplication registering of a location
    NSUInteger index = [self _indexForLocation:location];
    if (index == NSNotFound) {
        [self _startConnectionIfNeeded];
        // Send -startMonitoringWeatherChangesForLocation: to weatherinfod
        [self.remoteObject startMonitoringWeatherChangesForLocation:location];
        [self.monitoredLocations addObject:location];
    }
}

- (void)stopMonitoringCurrentLocationWeatherChanges
{
    if (self.isMonitoringCurrentLocationWeatherChanges == YES) {
        [self.remoteObject stopMonitoringCurrentLocationWeatherChanges];
        self.isMonitoringCurrentLocationWeatherChanges = NO;
        [self _stopConnectionIfNeeded];
    }
}

- (void)stopMonitoringWeatherChangesForLocation:(CLLocation *)location
{
    // Only stop updating if updates are being recieved for the location
    NSUInteger index = [self _indexForLocation:location];
    if (index != NSNotFound) {
        [self.remoteObject stopMonitoringWeatherChangesForLocation:location];
        [self.monitoredLocations removeObject:location];
        [self _stopConnectionIfNeeded];
    }
}

- (void)didUpdateWeather:(WBCity *)city
{
    if ([self.delegate respondsToSelector:@selector(weatherInfoManager: didUpdateWeather:)]) {
        //Call -weatherInfoManager:didUpdateWeather: on the main queue
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        if (mainQueue == dispatch_get_current_queue()) {
            [self.delegate weatherInfoManager:self didUpdateWeather:city];
        } else {
            dispatch_sync(mainQueue, ^{
                [self.delegate weatherInfoManager:self didUpdateWeather:city];
            });
        }
    }
}

- (void)didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(weatherInfoManager: didFailWithError:)]) {
        [self.delegate weatherInfoManager:self didFailWithError:error];
    }
}

- (void)dealloc
{
    [_connection invalidate];
    [_connection release];
    [_monitoredLocations release];
    [_remoteObject release];
    [super dealloc];
}

@end
