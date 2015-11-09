//
//  MarkerInfoTVC.m
//  MyMapBox
//
//  Created by bizappman on 4/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MarkerInfoTVC.h"
#import "MarkerEditTVC.h"
#import "MMMarker+Dao.h"
#import "MMRoutine+Dao.h"
#import "LocalImageUrl+Dao.h"
#import "CommonUtil.h"
#import "RoutineDetailMapViewController.h"
#import "PinMarkerRoutineSelectTVC.h"


@interface MarkerInfoTVC ()



@end

@implementation MarkerInfoTVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [self updateUI];
}

-(IBAction)markerEditDone:(UIStoryboardSegue *) segue{
    NSLog(@"marker edit done");
    //[self updateUI];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"editMarkerSegue"]) {
        UINavigationController *navController=(UINavigationController *)segue.destinationViewController;
        MarkerEditTVC *markerEditTVC=navController.viewControllers[0];
        markerEditTVC.marker=self.marker;
        markerEditTVC.markerCount=self.markerCount;
        markerEditTVC.allSubMarkers=self.allSubMarkers;
    }else if ([segue.identifier isEqualToString:@"showDetailMapSegue"]){
        RoutineDetailMapViewController *desVC=segue.destinationViewController;
        desVC.parentMarker=self.marker;
        MMMarker *marker=self.marker;
        desVC.routine=marker.belongRoutine;
    }else if([segue.identifier isEqualToString:@"pinMarkerSelectRoutineSegue"]){
        UINavigationController *navController=(UINavigationController *)segue.destinationViewController;
        PinMarkerRoutineSelectTVC *pinRoutineSelectTVC=navController.viewControllers[0];
        pinRoutineSelectTVC.markerNeedPin=self.marker;
        pinRoutineSelectTVC.needShowCurrentRoutine=YES;
    }
}

#pragma mark override
-(void)updateUI{
    [super updateUI];
    
    
    //if no http image found,use local image instead
    if([self.marker isKindOfClass:[MMMarker class]]&& [self.marker imageUrlsArrayIncludeSubMarkers].count==0){
        MMMarker *marker=self.marker;
        LocalImageUrl *localImageUrl=[[marker localImagesIncludingSubMarkers] firstObject];
        NSLog(@"load image from local url:%@",localImageUrl.fileName);
        UIImage *image=[CommonUtil loadImage:localImageUrl.fileName];
        if(image){
            [self.markerImage setImage:image];
            self.markerImage.contentMode=UIViewContentModeScaleAspectFill;
        }
    }

}

#pragma mark UI Action
-(IBAction)editButtonClick:(id)sender{
    [self performSegueWithIdentifier:@"editMarkerSegue" sender:nil];
}

-(IBAction)pinButtonClick:(id)sender{
    [self performSegueWithIdentifier:@"pinMarkerSelectRoutineSegue" sender:nil];
}

- (IBAction)showSubMarkerButtonClick:(id)sender {
    [self performSegueWithIdentifier:@"showDetailMapSegue" sender:nil];
}

-(void)markerImageClicked{
    if([self.marker isKindOfClass:[MMMarker class]]){
        
        MMMarker *marker=self.marker;
        
        if ([marker imageUrlsArrayIncludeSubMarkers].count>0||[marker localImagesIncludingSubMarkers].count>0) {
            self.photos=[NSMutableArray array];
            
            //http image
            for (NSString *urlString in [marker imageUrlsArrayIncludeSubMarkers]) {
                NSURL *url=[NSURL URLWithString:urlString];
                [self.photos addObject:[MWPhoto photoWithURL:url]];
            }
            
            //local image
            for (LocalImageUrl *localImageUrl in [marker localImagesIncludingSubMarkers]) {
                UIImage *image=[CommonUtil loadImage:localImageUrl.fileName];
                if(image){
                    [self.photos addObject:[MWPhoto photoWithImage:image]];
                }
            }
            
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            
            [browser setCurrentPhotoIndex:0];
            
            [self.navigationController pushViewController:browser animated:YES];
            [browser showNextPhotoAnimated:YES];
            [browser showPreviousPhotoAnimated:YES];
        }
    }
}

@end
