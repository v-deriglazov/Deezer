//
//  DZRequestManager.m
//  Deezer
//
//  Created by Vladimir Deriglazov on 17.06.17.
//  Copyright © 2017 Vladimir Deriglazov. All rights reserved.
//

#import "DZRequestManager.h"

@implementation DZRequestManager

+ (NSString *)baseURL
{
    return @"https://api.deezer.com/user";
}

+ (void)refreshUserWithID:(uint64_t)userID completion:(void(^)(BOOL result, NSDictionary *data))completion
{
    if (completion == NULL || userID == 0)
        return;
    
    NSString *str = [NSString stringWithFormat:@"%@/%llu", [self baseURL], userID];
    NSURL *url = [NSURL URLWithString:str];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        BOOL result = (error == nil);
        NSDictionary *dict = nil;
        if (result)
        {
            dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            result = [dict isKindOfClass:[NSDictionary class]];
        }
        completion(result, dict);
    }];
    [task resume];
}


+ (void)refreshPlaylistsForUserWithID:(uint64_t)userID completion:(void(^)(BOOL result, NSArray<NSDictionary *> *data))completion
{
    if (completion == NULL || userID == 0)
        return;
    [self fetchPlaylistsForUserWithID:userID toContainer:[NSMutableArray new] completion:completion];
}

+ (void)fetchPlaylistsForUserWithID:(uint64_t)userID toContainer:(NSMutableArray<NSDictionary *> *)playlistsData completion:(void(^)(BOOL result, NSArray<NSDictionary *> *data))completion
{
    NSString *offset = playlistsData.count > 0 ? [NSString stringWithFormat:@"?index=%lu", playlistsData.count] : @"";
    NSString *str = [NSString stringWithFormat:@"%@/%llu/playlists%@", [self baseURL], userID, offset];
    NSURL *url = [NSURL URLWithString:str];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        NSArray<NSDictionary *> *playlists = nil;
        NSUInteger totalCount = 0;
        do
        {
            if (data == nil || error != nil)
                break;
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if (dict == nil || ![dict isKindOfClass:[NSDictionary class]])
                break;
            
            playlists = dict[@"data"];
            if (![playlists isKindOfClass:[NSArray class]])
                playlists = nil;
            else
                totalCount = [dict[@"total"] unsignedIntegerValue];
        } while (NO);
        
        if (playlists == nil)
        {
            if (completion)
                completion(NO, nil);
            return;
        }
        
        [playlistsData addObjectsFromArray:playlists];
        if (playlistsData.count >= totalCount)
        {
            if (completion != NULL)
                completion(YES, playlistsData);
        }
        else
        {
            [self fetchPlaylistsForUserWithID:userID toContainer:playlistsData completion:completion];
        }
    }];
    [task resume];
}

@end
