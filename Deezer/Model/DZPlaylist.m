//
//  DZPlaylist.m
//  Deezer
//
//  Created by Vladimir Deriglazov on 17.06.17.
//  Copyright © 2017 Vladimir Deriglazov. All rights reserved.
//

#import "DZPlaylist.h"

static NSString *const kListIDKey = @"id";
static NSString *const kTitleKey = @"title";
static NSString *const kDurationKey = @"duration";
static NSString *const kRatingKey = @"rating";
static NSString *const kPictureKey = @"picture";
static NSString *const kTimeKey = @"creation_date";


@implementation DZPlaylist

+ (NSSet<DZPlaylist *> *)parseData:(NSArray<NSDictionary *> *)data
{
    __block NSMutableSet<DZPlaylist *> *result = [NSMutableSet new];
    __block NSMutableSet *playListIDs = [NSMutableSet new];
    [data enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        uint64_t listID = [obj[kListIDKey] longLongValue];
        if ([playListIDs containsObject:@(listID)])
        {
            NSParameterAssert(NO);
            return;
        }
        [playListIDs addObject:@(listID)];
        
        DZPlaylist *list = [DZPlaylist new];
        list.listID = listID;
        list.title = obj[kTitleKey];
        list.duration = [obj[kDurationKey] unsignedIntegerValue];
        list.rating = [obj[kRatingKey] unsignedIntegerValue];
        list.picture = obj[kPictureKey];
        list.creationTime = obj[kTimeKey];
        [result addObject:list];
    }];
    
    return result;
}

#pragma mark - 

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"id %llu, title %@\nduration %lu rating %lu\n time %@", self.listID, self.title, self.duration, self.rating, self.creationTime];
}

@end
