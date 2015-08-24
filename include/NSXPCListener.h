//
//  NSXPCListener.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-01-22.
//
//

#import "NSXPCListenerDelegate.h"

@interface NSXPCListener : NSObject
@property (nonatomic, assign) id <NSXPCListenerDelegate> delegate;
- (id)initWithMachServiceName:(NSString *)machServiceName;
- (void)invalidate;
- (void)resume;
@end

