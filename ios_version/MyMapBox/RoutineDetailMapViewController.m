//
//  RoutineDetailMapViewController.m
//  MyMapBox
//
//  Created by yufu on 15/4/13.
//  Copyright (c) 2015年 yufu. All rights reserved.
//
#import <GoogleMaps/GoogleMaps.h>
#import "RoutineDetailMapViewController.h"
#import "CommonUtil.h"
#import "MarkerInfoTVC.h"
#import "MarkerEditTVC.h"
#import "CloudManager.h"
#import "GoogleSearchTVC.h"

#import "MMRoutine+Dao.h"

#define SHOW_SEARCH_MODAL_SEGUE @"showSearchModalSegue"

@interface RoutineDetailMapViewController ()<RMMapViewDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *locateButton;
@property (weak, nonatomic) IBOutlet UIButton *syncButton;
@property (weak, nonatomic) IBOutlet UIToolbar *playRoutineToolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *SlidePlayButton;

@property(nonatomic,strong) GooglePlace *searchResult;
@property(nonatomic,strong) UIActionSheet *searchRMMarkerActionSheet;

@end

@implementation RoutineDetailMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init ui
    self.slideIndicator=-1;
    
    self.locateButton.layer.borderWidth=0.5f;
    self.locateButton.layer.cornerRadius = 4.5;
    self.syncButton.layer.borderWidth=0.5f;
    self.syncButton.layer.cornerRadius=4.5;
    
    UIBarButtonItem *searchButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonClick:)];
    UIBarButtonItem *addButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMarker:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:addButton,searchButton, nil];
    
    //init map
    self.mapView.maxZoom=17;
    
    self.mapView.zoom=15;
    
    self.mapView.bouncingEnabled=YES;
    
    self.mapView.delegate=self;
    
    self.mapView.showsUserLocation=YES;
    
    self.mapView.displayHeadingCalibration=YES;
    
    
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    
    NSLog(@"RoutineDetailMapViewTVC did load");
    
    [self updateMapUI];
    
    if([CommonUtil isFastNetWork]){
        [CloudManager syncMarkersByRoutineUUID:[self.routine uuid] withBlockWhenDone:^(NSError *error) {
            if(error){
                NSLog(@"error happened :%@",error.localizedDescription);
            }
            
            [self updateMapUI];
        }];
    }
    

}

-(void)viewWillAppear:(BOOL)animated{
}

-(void)viewDidAppear:(BOOL)animated{
    [self updateMapUI];
}

-(void)updateMapUI{
    [super updateMapUI];
    
    if(self.searchResult && [self.searchResult isLoaded]){
        CLLocationCoordinate2D coord=CLLocationCoordinate2DMake([self.searchResult.lat doubleValue], [self.searchResult.lng doubleValue]);
        [self addMarkerWithTitle:self.searchResult.title withCoordinate:coord withCustomData:self.searchResult];
        [self.mapView setCenterCoordinate:coord animated:YES];
    }
}

-(void)updateUIInSlideMode{
    [self.SlidePlayButton setImage:[UIImage imageNamed:@"icon_stop"]];
    
    [super updateUIInSlideMode];
}



-(void)updateUIInNormalMode{
    
    [self.SlidePlayButton setImage:[UIImage imageNamed:@"icon_play"]];

    [super updateUIInNormalMode];
}

#pragma mark - getter and setter

-(UIActionSheet *)searchRMMarkerActionSheet{
    if(!_searchRMMarkerActionSheet){
        _searchRMMarkerActionSheet=[[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:@"Add to Routine",@"Clear Search Result", nil];
    }
    return _searchRMMarkerActionSheet;
}

#pragma mark - UI action


- (IBAction)PlayButtonClick:(id)sender {
    [self slidePlayClick];
}

- (IBAction)PrevButtonClick:(id)sender {
    [self slidePrevClick];
}

- (IBAction)NextButtonClick:(id)sender {
    [self slideNextClick];
}

- (IBAction)refreshButtonClick:(id)sender {
    NSString *currentRoutineUUID=[self.routine uuid];
    [CloudManager syncMarkersByRoutineUUID:[self.routine uuid] withBlockWhenDone:^(NSError *error) {
        if(!error){
            self.routine=[MMRoutine queryMMRoutineWithUUID:currentRoutineUUID];
            if(self.routine){
                [self updateMapUI];
            }
        }
    }];
}

- (IBAction)locateButtonClick:(id)sender {
    NSLog(@"Locate Button CLick");
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

- (IBAction)addMarker:(id)sender {
    UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:@"Add Marker in Center",@"Add Marker with Image",@"Add Marker in Current Location", nil];
    [sheet showInView:self.view];
}

-(IBAction)searchButtonClick:(id)sender{
    [self performSegueWithIdentifier:SHOW_SEARCH_MODAL_SEGUE sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"markerDetailSegue"]) {
        MarkerInfoTVC *markerInfoTVC=segue.destinationViewController;
        markerInfoTVC.marker=((RMAnnotation *)sender).userInfo;
        markerInfoTVC.markerCount=[[self.routine allMarks] count];
    }else if ([segue.identifier isEqualToString:SHOW_SEARCH_MODAL_SEGUE]){
        UINavigationController *navController=(UINavigationController *)segue.destinationViewController;
        GoogleSearchTVC *desTVC=navController.viewControllers[0];
        desTVC.minLocation=CLLocationCoordinate2DMake([self.routine minLatInMarkers], [self.routine minLngInMarkers]);
        desTVC.maxLocation=CLLocationCoordinate2DMake([self.routine maxLatInMarkers], [self.routine maxLngInMarkers]);
    }
}

-(IBAction)searchDone:(UIStoryboardSegue *)segue{
    GoogleSearchTVC *sourceTVC=segue.sourceViewController;
    GooglePlace *searchPlace=sourceTVC.selectedPlace;
    
    self.searchResult=searchPlace;
}

-(IBAction)DeleteMarkerDone:(UIStoryboardSegue *)segue{
    self.currentMarker=nil;
    
    NSLog(@"prepare delete marker");
    MarkerEditTVC *markerEditTVC=segue.sourceViewController;
    MMMarker *marker=markerEditTVC.marker;
    if(marker){
        if([marker.isSync boolValue]){
            NSLog(@"mark delete marker id %@",marker.uuid);
            [marker markDelete];
        }else{
            [MMMarker removeMMMarker:marker];
        }
    }
}


#pragma mark - UIActionSheetDelegate


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet==self.searchRMMarkerActionSheet){
        switch (buttonIndex) {
            case addSearchResult2Routine:{
                MMMarker *newMarker=[MMMarker createMMMarkerInRoutine:self.routine
                                                              withLat:[self.searchResult.lat doubleValue]
                                                              withLng:[self.searchResult.lng doubleValue]];
                newMarker.title=self.searchResult.title;
                newMarker.category=[NSNumber numberWithUnsignedInteger:CategorySight];
                newMarker.iconUrl=@"sight_default";
                break;
            }
            case clearSearchResult:{
                
                break;
            }
            default:
                break;
        }
        
        self.searchResult=nil;
        [self updateMapUI];
    }else{
        MMMarker *newMarker=nil;
        switch (buttonIndex) {
            case addMarkerInCenter:{
                NSLog(@"add marker in center");
                newMarker=[MMMarker createMMMarkerInRoutine:self.routine
                                                    withLat:self.mapView.centerCoordinate.latitude
                                                    withLng:self.mapView.centerCoordinate.longitude];
                break;
            }
            case addMarkerWithImage :{
                NSLog(@"add marker with image");
                break;
            }
            case addMarkerInCurrentLocation:{
                NSLog(@"add marker in current location");
                newMarker=[MMMarker createMMMarkerInRoutine:self.routine
                                                    withLat:self.mapView.userLocation.coordinate.latitude
                                                    withLng:self.mapView.userLocation.coordinate.longitude];
                break;
            }
            default:
                break;
        }
        if(newMarker){
            [self addMarkerWithTitle:newMarker.title withCoordinate:CLLocationCoordinate2DMake([newMarker.lat doubleValue], [newMarker.lng doubleValue])
                      withCustomData:newMarker];
        }
    }
    
}

#pragma mark - RMMapViewDelegate

-(RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation{
    if(annotation.isUserLocationAnnotation)
        return nil;
    
    
    
    if ([annotation.userInfo isKindOfClass:[MMMarker class]]){
        MMMarker *modelMarker=annotation.userInfo;
        
        CGPoint anchorPoint;
        anchorPoint.x=0.5;
        anchorPoint.y=1;
        
        UIImage *iconImage=[UIImage imageNamed:modelMarker.iconUrl];
        
        if(!iconImage){
            iconImage=[UIImage imageNamed:@"default_default.png"];
        }
        
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:iconImage anchorPoint:anchorPoint];
        //RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"default_default"]anchorPoint:anchorPoint];
        
        
        
        marker.canShowCallout=YES;
        
        marker.rightCalloutAccessoryView=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return marker;
    }else if ([annotation.userInfo isKindOfClass:[GooglePlace class]]){
        CGPoint anchorPoint;
        anchorPoint.x=0.5;
        anchorPoint.y=1;
        
        UIImage *iconImage=[UIImage imageNamed:@"search_default"];
        
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:iconImage anchorPoint:anchorPoint];
        
        marker.canShowCallout=YES;
        
        marker.rightCalloutAccessoryView=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return marker;
    }else{
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"overview_star"]];
        
        marker.canShowCallout=YES;
        
        return marker;
    }

    return nil;
}

-(void) mapView:(RMMapView *)mapView annotation:(RMAnnotation *)annotation didChangeDragState:(RMMapLayerDragState)newState fromOldState:(RMMapLayerDragState)oldState{
    
    NSLog(@"change drag state %u",newState);
    
    if(newState==RMMapLayerDragStateNone){
        NSString *subTitle=[NSString stringWithFormat:@"lat: %f lng: %f",annotation.coordinate.latitude,annotation.coordinate.longitude];
        annotation.subtitle=subTitle;
        if ([annotation.userInfo isKindOfClass:[MMMarker class]]) {
            MMMarker *marker=(MMMarker *)annotation.userInfo;
            marker.lat=[NSNumber numberWithDouble:annotation.coordinate.latitude];
            marker.lng=[NSNumber numberWithDouble:annotation.coordinate.longitude];
            marker.updateTimestamp=[NSNumber numberWithLongLong:[CommonUtil currentUTCTimeStamp]];
            NSLog(@"Drage end update marker id:%@ location",marker.uuid);
            [self.routine updateLocation];
        }
    }
}


-(void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    if ([annotation.userInfo isKindOfClass:[GooglePlace class]]) {
        [self.searchRMMarkerActionSheet showInView:self.view];
    }else if ([annotation.userInfo isKindOfClass:[MMMarker class]]){
        self.currentMarker=annotation.userInfo;
        [self performSegueWithIdentifier:@"markerDetailSegue" sender:annotation];
    }
}

-(void)tapOnLabelForAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    NSLog(@"tap on label");
}


-(BOOL)mapView:(RMMapView *)mapView shouldDragAnnotation:(RMAnnotation *)annotation{
    if ([annotation.userInfo isKindOfClass:[GooglePlace class]]) {
        return NO;
    }else{
        return YES;
    }
}
@end
