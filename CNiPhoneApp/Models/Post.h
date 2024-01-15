//
//  Post.h
//  CNApp
//
//  Created by Manpreet Singh on 6/26/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "User.h"
#import "Comment.h"
#import "PostCount.h"
#import "PollItem.h"

static NSString* const CONTENT_TYPE_POST = @"post";
static NSString* const CONTENT_TYPE_ASSIGNMENT = @"assignment";
static NSString* const CONTENT_TYPE_EVENT = @"event";
static NSString* const CONTENT_TYPE_QUIZ = @"quiz";
static NSString* const CONTENT_TYPE_POLL = @"survey";
static NSString* const CONTENT_TYPE_CLASSCAST = @"classcast";
static NSString* const CONTENT_TYPE_EMAIL = @"email";
static NSString* const CONTENT_TYPE_SHARELINK = @"sharelink";

@interface Post : NSObject

@property (nonatomic, strong) NSString *postId;
@property (nonatomic, strong) NSString *displayTime;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *rawText;
@property (nonatomic, strong) NSString *shortRawText;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *postType;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) PostCount *count;
@property (nonatomic, strong) NSString *userPosition;
@property (nonatomic, strong) NSDate *postDate;

@property (nonatomic, strong) NSArray *links;
@property (nonatomic, strong) NSArray *videos;
@property (nonatomic, strong) NSArray *attachments;
@property (nonatomic, strong) NSMutableArray *pictures;

@property (nonatomic, strong) NSArray *courses;
@property (nonatomic, strong) NSArray *conexuses;

@property (nonatomic, strong) NSArray *pox;

// ShareLink
@property (nonatomic, strong) NSString *originalShareLink;
@property (nonatomic, strong) NSString *shareLink;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) Picture *shareLinkPicture;

// Events
@property (nonatomic, strong) NSString *eventDisplayStartTime;
@property (nonatomic, strong) NSString *eventDisplayEndTime;
@property (nonatomic, strong) NSString *eventWhere;

// Polls
@property (nonatomic, strong) NSArray *pollItems;

@property (nonatomic) BOOL isLiked;
@property (nonatomic) BOOL isDeletable;
@property (nonatomic) BOOL isEditable;
@property (nonatomic) BOOL isFromAdmin;
@property (nonatomic) BOOL isOwner;
@property (nonatomic) BOOL isRepostable;

@property (nonatomic) BOOL hasAttachments;
@property (nonatomic) BOOL hasLinks;

+ (Post *)postFromJSON:(NSDictionary *)dict;
+ (NSArray *)postsFromJSONArray:(NSArray *)arr;

@property (nonatomic) CGFloat postShortContentHeight;
@property (nonatomic) CGFloat postFullContentHeight;


@end
