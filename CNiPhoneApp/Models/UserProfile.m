//
//  UserProfile.m
//  CNApp
//
//  Created by Manpreet Singh on 7/11/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "UserProfile.h"
#import "Tools.h"

@implementation UserProfile

+ (UserProfile *)profileFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"about": @"about",
                              @"gender": @"gender",
                              @"primary_language_name": @"primaryLanguage",
                              @"other_languages": @"otherLanguages",
                              @"time_zone_name": @"timeZone",
                              @"interests": @"interests",
                              @"website": @"website",
                              @"twitter_name": @"twitterName"
                              };
    UserProfile *profile = [UserProfile objectFromJSONObject:dict mapping:mapping];
    profile.about = [Tools replaceHtmlCharacters:profile.about];
    profile.country = [[dict objectForKey:@"origin_country"] objectForKey:@"name"];
    if ([[dict objectForKey:@"position"] count]>0) profile.currentPosition = [UserProfilePosition positionFromJSON:[dict objectForKey:@"position"]];
    if ([[dict objectForKey:@"current_work"] count]>0) profile.currentWork = [UserProfileWork workFromJSON:[dict objectForKey:@"current_work"]];
    profile.schools = [UserProfileSchool schoolsFromJSONArray:[dict objectForKey:@"schools"]];
    profile.works = [UserProfileWork worksFromJSONArray:[dict objectForKey:@"works"]];
    //if ([[dict objectForKey:@"tag_line"] count] > 0) profile.tagLine = [[dict objectForKey:@"tag_line"] objectAtIndex:0];
    profile.gender = [profile.gender capitalizedString];
    return profile;
}

@end
