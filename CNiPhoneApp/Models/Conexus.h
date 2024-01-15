//
//  Conexus.h
//  CNApp
//
//  Created by Manpreet Singh on 7/1/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"
#import "ConexusUser.h"

@interface Conexus : NSObject

@property (nonatomic, strong) NSString *conexusId;
@property (nonatomic, strong) NSString *conexusNumber;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *about;
@property (nonatomic, strong) NSString *displayTime;
@property (nonatomic, strong) NSString *logoURL;
@property (nonatomic, strong) NSString *userPosition;

+ (Conexus *)conexusFromJSON:(NSDictionary *)dict;
+ (NSArray *)conexusesFromJSONArray:(NSArray *)arr;

@end
