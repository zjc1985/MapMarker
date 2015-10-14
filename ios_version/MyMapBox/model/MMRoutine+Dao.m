//
//  MMRoutine+Extension.m
//  MyMapBox
//
//  Created by bizappman on 5/11/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMRoutine+Dao.h"
#import "AppDelegate.h"
#import "CommonUtil.h"
#import "MMOvMarker+Dao.h"
#import "MMMarker+Dao.h"
#import "MMTreeNode+Dao.h"

@import CoreData;

@implementation MMRoutine (Dao)

#pragma mark - instance method


+(MMRoutine *)queryMMRoutineWithUUID:(NSString *)uuid{
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSEntityDescription *e=[NSEntityDescription entityForName:@"MMRoutine"
                                       inManagedObjectContext:[CommonUtil getContext]];
    request.entity=e;
    NSSortDescriptor *sd=[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors=@[sd];
    request.predicate= [NSPredicate predicateWithFormat:@"uuid == %@",uuid];
    NSError *error;
    NSArray *result=[[CommonUtil getContext] executeFetchRequest:request error:&error];
    if(!result){
        [NSException raise:@"Fetch failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    
    return result.firstObject;
}

+(MMRoutine *)createMMRoutineWithLat:(double)lat withLng:(double)lng withUUID:(NSString *)uuid{
    MMRoutine *result=[self queryMMRoutineWithUUID:uuid];
    if(result){
        return result;
    }else{
        result=[NSEntityDescription insertNewObjectForEntityForName:@"MMRoutine" inManagedObjectContext:[CommonUtil getContext]];
        result.uuid=uuid;
        result.title=@"New Routine";
        result.mycomment=@"";
        result.lat=[NSNumber numberWithDouble:lat];
        result.lng=[NSNumber numberWithDouble:lng];
        result.isDelete=[NSNumber numberWithBool:NO];
        result.isSync=[NSNumber numberWithBool:NO];
        result.cachProgress=[NSNumber numberWithFloat:0];
        return result;
    }
}

+(MMRoutine *)createMMRoutineWithLat:(double)lat withLng:(double)lng{
    NSUUID *uuid=[[NSUUID alloc]init];
    return [self createMMRoutineWithLat:lat withLng:lng withUUID:[uuid UUIDString]];
}

+(void)removeRoutine:(MMRoutine *)routine{
    [[CommonUtil getContext]deleteObject:routine];
}

+(NSArray *)fetchAllModelRoutines{
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSEntityDescription *e=[NSEntityDescription entityForName:@"MMRoutine"
                                       inManagedObjectContext:[CommonUtil getContext]];
    request.entity=e;
    NSSortDescriptor *sd=[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors=@[sd];
    request.predicate= [NSPredicate predicateWithFormat:@"isDelete == NO"];
    NSError *error;
    NSArray *result=[[CommonUtil getContext] executeFetchRequest:request error:&error];
    if(!result){
        [NSException raise:@"Fetch failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    
    return result;
}

+(NSArray *)fetchALLRoutinesIncludeMarkDelete{
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSEntityDescription *e=[NSEntityDescription entityForName:@"MMRoutine"
                                       inManagedObjectContext:[CommonUtil getContext]];
    request.entity=e;
    NSSortDescriptor *sd=[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors=@[sd];
    NSError *error;
    NSArray *result=[[CommonUtil getContext] executeFetchRequest:request error:&error];
    if(!result){
        [NSException raise:@"Fetch failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    
    return result;
}

+(NSArray *)fetchAllCachedModelRoutines{
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSEntityDescription *e=[NSEntityDescription entityForName:@"MMRoutine"
                                       inManagedObjectContext:[CommonUtil getContext]];
    request.entity=e;
    NSSortDescriptor *sd=[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors=@[sd];
    request.predicate= [NSPredicate predicateWithFormat:@"cachProgress > 0"];
    NSError *error;
    NSArray *result=[[CommonUtil getContext] executeFetchRequest:request error:&error];
    if(!result){
        [NSException raise:@"Fetch failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    
    return result;
}

-(void)deleteSelf{
    for (MMOvMarker *eachOvMarker in self.ovMarkers) {
        [eachOvMarker deleteSelf];
    }
    
    for (MMTreeNode *eachTreeNode in self.treeNodes) {
        [eachTreeNode deleteSelf];
    }
    
    if(self.isSync){
        self.isDelete=[NSNumber numberWithBool:YES];
        NSNumber *timestamp=[NSNumber numberWithLongLong:[CommonUtil currentUTCTimeStamp]];
        self.updateTimestamp=timestamp;
    }else{
        [MMRoutine removeRoutine:self];
    }
}

-(void)updateLocation{
    NSMutableArray *latArray=[[NSMutableArray alloc]init];
    NSMutableArray *lngArray=[[NSMutableArray alloc]init];
    
    for (MMMarker *eachMarker in self.markers) {
        [latArray addObject:eachMarker.lat];
        [lngArray addObject:eachMarker.lng];
    }
    
    self.lat=[NSNumber numberWithDouble: [self refineAverage:latArray]];
    self.lng=[NSNumber numberWithDouble: [self refineAverage:lngArray]];
    
    NSNumber *timestamp=[NSNumber numberWithLongLong:[CommonUtil currentUTCTimeStamp]];
    self.updateTimestamp=timestamp;
}

-(double)minLatInMarkers{
    MMMarker *first=[[self.markers allObjects] firstObject];
    double minLat=[first.lat doubleValue];
    
    for (MMMarker *each in self.markers) {
        if([each.lat doubleValue]<minLat){
            minLat=[each.lat doubleValue];
        }
    }
    
    return minLat;
}

-(double)minLngInMarkers{
    MMMarker *first=[[self.markers allObjects] firstObject];
    double minLng=[first.lng doubleValue];
    for (MMMarker *each in self.markers) {
        if([each.lng doubleValue]<minLng){
            minLng=[each.lng doubleValue];
        }
    }
    return minLng;
}

-(double)maxLatInMarkers{
    MMMarker *first=[[self.markers allObjects] firstObject];
    double maxLat=[first.lat doubleValue];
    for (MMMarker *each in self.markers) {
        if([each.lat doubleValue]>maxLat){
            maxLat=[each.lat doubleValue];
        }
    }
    return maxLat;
}

-(double)maxLngInMarkers{
    MMMarker *first=[[self.markers allObjects] firstObject];
    double maxLng=[first.lng doubleValue];
    for (MMMarker *each in self.markers) {
        if([each.lng doubleValue]>maxLng){
            maxLng=[each.lng doubleValue];
        }
    }
    return maxLng;
}

-(NSArray *)allMarks{
    NSArray *markers=[self.markers allObjects];
    NSMutableArray *result=[[NSMutableArray alloc]init];
    for (MMMarker *each in markers) {
        if(![each.isDelete boolValue]){
            [result addObject:each];
        }
    }
    return result;
}

-(NSArray *)headTreeNodes{
    NSMutableArray *result=[[NSMutableArray alloc]init];
    
    //for migration, if no treeNodes found, then create them according to markers
    NSLog(@"%@",@([[self allMarks] count]));
    if ([self.treeNodes allObjects].count==0) {
        for (MMMarker *eachMark in [self allMarks]) {
            [MMTreeNode createNodeWithParentNode:nil withMarkerId:eachMark.uuid belongRoutine:self];
        }
    }
    
    for (MMTreeNode *node in [self.treeNodes allObjects]) {
        if((![node.isDelete boolValue]) && (!node.parentNode)){
            [result addObject:node];
        }
    }
    
    return result;
}

-(NSUInteger)maxSlideNum{
    NSArray *markers=[self allMarks];
    NSUInteger maxSlideNum=0;
    for (MMMarker *marker in markers) {
        if([marker.slideNum unsignedIntegerValue]>maxSlideNum){
            maxSlideNum=[marker.slideNum unsignedIntegerValue];
        }
    }
    return maxSlideNum;
}

-(NSArray *)allOvMarks{
    NSArray *ovMarkers=[self.ovMarkers allObjects];
    NSMutableArray *result=[[NSMutableArray alloc]init];
    for (MMOvMarker *each in ovMarkers) {
        if(![each.isDelete boolValue]){
            [result addObject:each];
        }
    }
    return result;
}

-(BOOL)isMarkersSyncWithCloud{
    if([[self.markers allObjects] count]==0){
        return NO;
    }
    
    BOOL result=YES;
    
    for (MMMarker *marker in [self allMarks]) {
        if(![marker.isSync boolValue]){
            result=NO;
        }
    }
    
    return result;
}

#pragma mark - private method

-(double)refineAverage:(NSMutableArray*)numbers{
    NSMutableArray *refineArray=[[NSMutableArray alloc]init];
    double e=[self average:numbers];
    double d=[self sDeviation:numbers];
    
    for (NSNumber *number in numbers) {
        if (fabs([number doubleValue]-e)<=d) {
            [refineArray addObject:number];
        }
    }
    
    return [self average:refineArray];
}

-(double)average:(NSMutableArray *)numbers{
    double sum=0;
    double result=0;
    
    for (NSNumber *number in numbers) {
        sum=sum+[number doubleValue];
    }
    
    result=sum/[numbers count];
    return result;
}

-(double)sDeviation:(NSMutableArray *)numbers{
    if([numbers count]==0){
        return 0;
    }
    double e=[self average:numbers];
    double sum=0;
    for (NSNumber *number in numbers) {
        sum=sum+([number doubleValue]-e)*([number doubleValue]-e);
    }
    return pow(sum/[numbers count], 0.5);
}

-(NSDictionary *)convertToDictionary{
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    
    [dic setValue:self.mycomment forKey:KEY_ROUTINE_DESCRITPION];
    [dic setValue:self.title forKey:KEY_ROUTINE_TITLE];
    [dic setValue:self.isDelete forKey:KEY_ROUTINE_IS_DELETE];
    [dic setValue:self.updateTimestamp forKey:KEY_ROUTINE_UPDATE_TIME];
    [dic setValue:self.lat forKey:KEY_ROUTINE_LAT];
    [dic setValue:self.lng forKey:KEY_ROUTINE_LNG];
    [dic setValue:self.isSync forKey:KEY_ROUTINE_IS_SYNCED];
    [dic setValue:self.uuid forKey:KEY_ROUTINE_UUID];

    return dic;
}















@end
