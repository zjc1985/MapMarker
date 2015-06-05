//
//  MMMarker+Dao.h
//  MyMapBox
//
//  Created by bizappman on 5/11/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMMarker.h"

#define KEY_MARKER_ICON_URL @"iconUrl"
#define KEY_MARKER_UUID @"uuid"
#define KEY_MARKER_CATEGORY @"category"
#define KEY_MARKER_TITLE @"title"
#define KEY_MARKER_SLIDE_NUM @"slideNum"
#define KEY_MARKER_LAT @"lat"
#define KEY_MARKER_LNG @"lng"
#define KEY_MARKER_MYCOMMENT @"mycomment"
#define KEY_MARKER_ADDRESS @"address"
#define KEY_MARKER_OFFSETX @"offsetX"
#define KEY_MARKER_OFFSETY @"offsetY"
#define KEY_MARKER_ROUTINE_ID @"routineId"
#define KEY_MARKER_IS_DELETE @"isDelete"
#define KEY_MARKER_IS_SYNCED @"isSynced"
#define KEY_MARKER_UPDATE_TIME @"updateTime"
#define KEY_MARKER_IMAGE_URLS @"imgUrls"

typedef enum : NSUInteger {
    CategoryArrivalLeave = 1,
    CategorySight = 2,
    CategoryHotel = 3,
    CategoryFood=4,
    CategoryInfo=5,
    CategoryOverview=6
} MMMarkerCategory;

@interface MMMarker (Dao)

+(MMMarker *)createMMMarkerInRoutine:(MMRoutine *)routine withLat:(double)lat withLng:(double)lng;

+(MMMarker *)createMMMarkerInRoutine:(MMRoutine *)routine withLat:(double)lat withLng:(double)lng withUUID:(NSString *)uuid;

+(MMMarker *)queryMMMarkerWithUUID:(NSString *)uuid;

+(void)removeMMMarker:(MMMarker *)marker;

+(NSString *)CategoryNameWithMMMarkerCategory:(MMMarkerCategory)categoryNum;

-(void)markDelete;

-(NSString *)categoryName;

-(NSString *)subDescription;

-(NSArray *)imageUrlsArray;

-(void)addImageUrl:(NSString *)imgUrl;

-(void)removeImageUrl:(NSString *)imgUrl;

-(NSDictionary *)convertToDictionary;

@end
