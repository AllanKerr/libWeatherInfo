//
//  WBInfoWorker.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-07-06.
//
//

#import "NSXPCConnection.h"
#import "WBInfoWorkerInterface.h"
#import "WBCity.h"

@class WBInfoService;
@interface WBInfoWorker : NSObject <WBInfoWorkerInterface>
- (id)initWithConnection:(NSXPCConnection *)connection infoService:(WBInfoService *)infoService;
- (void)didUpdateCity:(WBCity *)city;
- (void)didFailWithError:(NSError *)error;
@end
