//
//  TWCValidator.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2014-12-24.
//
//

@interface TWCValidator : NSObject
@property (nonatomic, assign) id delegate;
+ (TWCValidator *)sharedValidator;
+ (void)clearSharedCityUpdater;
- (void)autocompleteLocation:(NSString *)location;
- (void)cancel;
@end
