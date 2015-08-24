//
//  DayForecast.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-01-29.
//
//

@interface DayForecast : NSObject
@property (nonatomic, copy) NSString *high;
@property (nonatomic, copy) NSString *low;
@property (nonatomic) int icon;
@property (nonatomic) int dayOfWeek;
@property (nonatomic) int dayNumber;
@end
