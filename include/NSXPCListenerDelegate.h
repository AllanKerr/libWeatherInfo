//
//  NSXPCListenerDelegate.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-01-22.
//
//

#import "NSXPCConnection.h"

@class NSXPCListener;
@protocol NSXPCListenerDelegate <NSObject>
@optional
- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)connection;
@end
