//
//  WBInfoWorker.m
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-07-06.
//
//

#import "WBInfoWorker.h"
#import "WBInfoService.h"
#import "WBWeatherInfoManagerInterface.h"
#import <CoreLocation/CoreLocation.h>

@interface WBInfoWorker ()
@property (nonatomic, assign) WBInfoService *infoService;
@property (nonatomic, retain) id <WBWeatherInfoManagerInterface>remoteObject;
@end

@implementation WBInfoWorker

- (id)initWithConnection:(NSXPCConnection *)connection infoService:(WBInfoService *)infoService
{
    if (self = [super init]) {
        // establish the interface with WBWeatherInfoManager
        NSXPCInterface *serverInterface = [NSXPCInterface interfaceWithProtocol:@protocol(WBInfoWorkerInterface)];
        NSXPCInterface *clientInterface = [NSXPCInterface interfaceWithProtocol:@protocol(WBWeatherInfoManagerInterface)];
        [clientInterface setClass:[WBCity class] forSelector:@selector(didUpdateWeather:) argumentIndex:0 ofReply:NO];
        [clientInterface setClass:[NSError class] forSelector:@selector(didFailWithError:) argumentIndex:0 ofReply:NO];
        
        // start the connection
        [connection setRemoteObjectInterface:clientInterface];
        [connection setExportedInterface:serverInterface];
        [connection setExportedObject:self];
        [connection resume];
        
        self.remoteObject = [connection remoteObjectProxy];
        self.infoService = infoService;
        
        connection.invalidationHandler = ^(){
            // called when WBWeatherInfoManager exits unexpectedly
            [self.infoService invalidateWorker:self];
            [connection setExportedObject:nil];
            self.remoteObject = nil;
        };
    }
    return self;
}

- (void)startMonitoringCurrentLocationWeatherChanges
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.infoService registerWorkerForCurrentLocationUpdates:self];
    });
}

- (void)startMonitoringWeatherChangesForLocation:(CLLocation *)location
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.infoService registerWorker:self forLocationUpates:location];
    });
}

- (void)stopMonitoringCurrentLocationWeatherChanges
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.infoService unregisterWorkerForCurrentLocationUpdates:self];
    });
}

- (void)stopMonitoringWeatherChangesForLocation:(CLLocation *)location
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.infoService unregisterWorker:self forLocationUpates:location];
    });
}

- (void)didUpdateCity:(WBCity *)city
{
    [self.remoteObject didUpdateWeather:city];
}

- (void)didFailWithError:(NSError *)error
{
    [self.remoteObject didFailWithError:error];
}

- (void)dealloc
{
    [_remoteObject release];
    [super dealloc];
}

@end
