//
//  WBInfoService.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-07-06.
//
//

#import "NSXPCListenerDelegate.h"
#import "WBInfoWorker.h"
#import "WBInfoUpdater.h"

@interface WBInfoService : NSObject <CLLocationManagerDelegate, NSXPCListenerDelegate, WBInfoUpdaterDelegate>
- (id)initWithServiceName:(NSString *)serviceName;
- (void)registerWorker:(WBInfoWorker *)worker forLocationUpates:(CLLocation *)location;
- (void)registerWorkerForCurrentLocationUpdates:(WBInfoWorker *)worker;
- (void)unregisterWorker:(WBInfoWorker *)worker forLocationUpates:(CLLocation *)location;
- (void)unregisterWorkerForCurrentLocationUpdates:(WBInfoWorker *)worker;
- (void)invalidateWorker:(WBInfoWorker *)worker;
- (void)systemWillSleep;
- (void)systemWillPowerOn;
@end
