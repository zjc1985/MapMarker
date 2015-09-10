//
//  GAutoQueryResult.m
//  MyMapBox
//
//  Created by bizappman on 7/21/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "GooglePredictionResult.h"

@interface GooglePredictionResult()

@property (nonatomic, strong) NSDictionary * dictionary;

@end

@implementation GooglePredictionResult

-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self=[super init];
    if(self){
        self.dictionary=dictionary;
    }
    return self;
}

-(NSString *)description{
    return [self.dictionary objectForKey:@"description"];
}

-(NSString *)placeId{
    return [self.dictionary objectForKey:@"place_id"];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self.placeId isEqualToString:((GooglePredictionResult*)other).placeId];
}

- (NSUInteger)hash {
    return [self.placeId hash];
}

@end
