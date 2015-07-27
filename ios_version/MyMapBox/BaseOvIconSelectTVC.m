//
//  BaseOvIconSelectTVC.m
//  MyMapBox
//
//  Created by bizappman on 7/27/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "BaseOvIconSelectTVC.h"

@interface BaseOvIconSelectTVC ()

@end

@implementation BaseOvIconSelectTVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - getter and setter
-(NSArray *)allOvIconUrls{
    if(!_allOvIconUrls){
        NSMutableArray *urlArray=[[NSMutableArray alloc]init];
        for (NSInteger i=0; i<12; i++) {
            NSString *url=[NSString stringWithFormat:@"ov_%i",i];
            [urlArray addObject:url];
        }
        _allOvIconUrls=urlArray;
    }
    
    return _allOvIconUrls;
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allOvIconUrls.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self reUseCellName] forIndexPath:indexPath];
    
    cell.textLabel.text=[self.allOvIconUrls objectAtIndex:indexPath.row];
    cell.imageView.image=[UIImage imageNamed:[self.allOvIconUrls objectAtIndex:indexPath.row]];
    
    if ([cell.textLabel.text isEqualToString:self.selectedUrl]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}




@end
