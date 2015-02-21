//
//  RCReplyEntity.m
//  JLRubyChina
//
//  Created by Lee jimney on 12/10/13.
//  Copyright (c) 2013 jimneylee. All rights reserved.
//

#import "RCReplyEntity.h"
#import "NSDate+RubyChina.h"
#import "RCRegularParser.h"
#import "NSString+Emojize.h"

@implementation RCReplyEntity

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDictionary:(NSDictionary*)dic
{
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    self = [super initWithDictionary:dic];
    if (self) {
        if (ForumBaseAPIType_RubyChina == FORUM_BASE_API_TYPE) {
            self.replyId = dic[JSON_ID];
            self.body = dic[JSON_BODY];
            self.createdAtDate = [NSDate dateFromSourceDateString:dic[JSON_CREATEED_AT]];
            self.updatedAtDate = [NSDate dateFromSourceDateString:dic[JSON_UPDATEED_AT]];
            self.user = [RCUserEntity entityWithDictionary:dic[JSON_USER]];
            
            [self parseAllKeywords];
        }
        else {
            self.replyId = dic[JSON_ID];
            self.body = dic[JSON_CONTENT];
            NSString* createTimestamp = dic[JSON_CREATED];
            if (createTimestamp) {
                self.createdAtDate = [NSDate dateWithTimeIntervalSince1970:[createTimestamp doubleValue]];
            }
            self.user = [RCUserEntity entityWithDictionary:dic[JSON_MEMBER]];
            
            [self parseAllKeywords];
        }
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)entityWithDictionary:(NSDictionary*)dic
{
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    RCReplyEntity* entity = [[RCReplyEntity alloc] initWithDictionary:dic];
    return entity;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// 识别出 表情 at某人 share话题 标签
- (void)parseAllKeywords
{
    if (self.body.length) {
        // parse emotion first
        self.body = [self.body emojizedString];
        
        NSString* trimedString = self.body;
        self.imageUrlsArray = [RCRegularParser imageUrlsInString:self.body trimedString:&trimedString];
        self.body = trimedString;
        
        if (!self.atPersonRanges) {
            self.atPersonRanges = [RCRegularParser keywordRangesOfAtPersonInString:self.body];
        }
        if (!self.sharpFloorRanges) {
            self.sharpFloorRanges = [RCRegularParser keywordRangesOfSharpFloorInString:self.body];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)floorNumberString
{
    if (!_floorNumberString.length) {
        NSString* louString = nil;
        switch (_floorNumber) {
            case 1:
                louString = @"沙发";
                break;
            case 2:
                louString = @"板凳";
                break;
            case 3:
                louString = @"地板";
                break;
            default:
                louString = [NSString stringWithFormat:@"%luu楼",(unsigned long) _floorNumber];
        }
        _floorNumberString = [louString copy];
    }
    return _floorNumberString;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// inline sort by reply id, remove it when api return sorted array
- (NSComparisonResult)compare:(RCReplyEntity*)other
{
    return [self.replyId compare:other.replyId];
}

@end
