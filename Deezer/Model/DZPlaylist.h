//
//  DZPlaylist.h
//  Deezer
//
//  Created by Vladimir Deriglazov on 17.06.17.
//  Copyright © 2017 Vladimir Deriglazov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DZPlaylist : NSObject

@property (nonatomic) uint64_t listID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) NSUInteger duration;
@property (nonatomic) NSUInteger rating;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, strong) NSString *creationTime;

+ (NSSet<DZPlaylist *> *)parseData:(NSArray<NSDictionary *> *)data;

@end
