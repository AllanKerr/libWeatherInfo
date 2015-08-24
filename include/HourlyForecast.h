//
//  HourlyForecast.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-01-29.
//
//

@interface HourlyForecast : NSObject
@property (nonatomic) int eventType;              
@property (nonatomic, copy) NSString *time;
@property (nonatomic) int hourIndex;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic) int conditionCode;
@property (nonatomic) float percentPrecipitation;                
@end
