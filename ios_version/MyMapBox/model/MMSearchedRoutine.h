//
//  MMSearchedRoutine.h
//  MyMapBox
//
//  Created by bizappman on 6/12/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonUtil.h"

@class MMSearchedOvMarker,MMSearchdeMarker;

@interface MMSearchedRoutine  : NSObject <Routine>

@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * lng;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * mycomment;
@property (nonatomic, strong,readonly) NSString * uuid;
@property (nonatomic,strong) NSNumber *isLoad;

@property(nonatomic,strong)NSString *userName;
@property(nonatomic,strong)NSString *userId;//leanCloud object id

@property (nonatomic, strong,readonly) NSSet *markers;
@property (nonatomic, strong,readonly) NSSet *ovMarkers;


-(instancetype)initWithUUID:(NSString *)uuid withLat:(NSNumber *)lat withLng:(NSNumber *)lng;

-(void)addOvMarkersObject:(MMSearchedOvMarker *)value;
-(void)addMarkersObject:(MMSearchdeMarker *)value;

@end
