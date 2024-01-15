//
//  UserProfile.h
//  CNApp
//
//  Created by Manpreet Singh on 7/11/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"
#import "UserProfileSchool.h"
#import "UserProfileWork.h"
#import "UserProfilePosition.h"

@interface UserProfile : NSObject

@property (nonatomic, strong) NSString *about;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *primaryLanguage;
@property (nonatomic, strong) NSDictionary *otherLanguages;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *timeZone;
@property (nonatomic, strong) NSArray *interests;
@property (nonatomic, strong) NSString *tagLine; // need to do ojectAtIndex:0
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *twitterName;

//@property (nonatomic, strong) NSString *lastVisited;

@property (nonatomic, strong) NSArray *schools;
@property (nonatomic, strong) NSArray *works;
@property (nonatomic, strong) UserProfileWork *currentWork;
@property (nonatomic, strong) UserProfilePosition *currentPosition;

+ (UserProfile *)profileFromJSON:(NSDictionary *)dict;

@end
