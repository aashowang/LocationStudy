//
//  ViewController.m
//  LocationStudy
//
//  Created by TangTieshan on 15/7/10.
//  Copyright (c) 2015年 TangTieshan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //定位管理器
    _locationManager = [[CLLocationManager alloc] init];
    
    _geocoder=[[CLGeocoder alloc]init];
    
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"定位服务器当前可能尚未打开，请设置打开");
        return;
    }
    else
    {
        NSLog(@"已经开启定位功能");
    }
    
    //如果没有授权则请求用户授权
    NSLog(@"[CLLocationManager authorizationStatus] = %d", [CLLocationManager authorizationStatus]);
    NSLog(@"kCLAuthorizationStatusAuthorizedWhenInUse");
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 100.0f;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f)
    {
        [_locationManager requestWhenInUseAuthorization];
    }
    
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, 60, 280, 35);
    button.backgroundColor = [UIColor greenColor];
    [button setTitle:@"Action Sheet" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    _locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, 280, 300)];
    _locationLabel.layer.cornerRadius = 10.0f;
    _locationLabel.layer.masksToBounds = NO;
    _locationLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _locationLabel.layer.shadowOffset = CGSizeMake(0, 1);
    _locationLabel.layer.shadowOpacity = 0.5f;
    _locationLabel.layer.shadowRadius = 2.0f;
    _locationLabel.numberOfLines = 0;
    _locationLabel.backgroundColor = [UIColor whiteColor];
    _locationLabel.font = [UIFont systemFontOfSize:20];
    _locationLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_locationLabel];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonClicked
{
    [_locationManager startUpdatingLocation];
    NSLog(@"startUpdatingLocation");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation * currentLocation = [locations lastObject];
    NSLog(@"latitude = %f", currentLocation.coordinate.latitude);
    NSLog(@"longitude = %f", currentLocation.coordinate.longitude);
    NSLog(@"altitude = %f", currentLocation.altitude);
    
    NSLog(@"定位成功");
    
    [self getAddressByLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error = %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [_locationManager requestWhenInUseAuthorization];
            }
            break;
        default:
            break;
    }
    
}

#pragma mark 根据坐标取得地名
-(void)getAddressByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude{
    //反地理编码
    CLLocation *location=[[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark=[placemarks firstObject];
        NSLog(@"详细信息:%@",placemark.addressDictionary);
        NSDictionary * dic = placemark.addressDictionary;
        
        _locationLabel.text = [[dic objectForKey:@"FormattedAddressLines"] firstObject];
        
        NSString * messagestr = [NSString stringWithFormat:@"国家：%@\n城市：%@\nformattedAddressLines:%@\nName:%@\n街道：%@\nstate:%@\nSubLocality:%@\nSubThoroughfare:%@\nThoroughfare:%@", [dic objectForKey:@"Country"], [dic objectForKey:@"City"], [[dic objectForKey:@"FormattedAddressLines"] firstObject], [dic objectForKey:@"Name"], [dic objectForKey:@"Street"], [dic objectForKey:@"State"], [dic objectForKey:@"SubLocality"], [dic objectForKey:@"SubThoroughfare"], [dic objectForKey:@"Thoroughfare"]];
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"定位结果" message:messagestr delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        
    }];
}

@end
