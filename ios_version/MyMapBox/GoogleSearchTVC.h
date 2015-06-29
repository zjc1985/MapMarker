//
//  GoogleSearchTVC.h
//  MyMapBox
//
//  Created by bizappman on 6/29/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GooglePlace+Dao.h"

@interface GoogleSearchTVC : UITableViewController

//in
@property(nonatomic)CLLocationCoordinate2D minLocation;
@property(nonatomic)CLLocationCoordinate2D maxLocation;


//out
@property(nonatomic,strong)GooglePlace *selectedPlace;

@end
