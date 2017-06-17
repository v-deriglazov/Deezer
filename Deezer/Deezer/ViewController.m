//
//  ViewController.m
//  Deezer
//
//  Created by Vladimir Deriglazov on 17.06.17.
//  Copyright © 2017 Vladimir Deriglazov. All rights reserved.
//

#import "ViewController.h"

static NSString *const kCellID = @"cellID";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellID];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? NSLocalizedString(@"Personal Info", nil) : NSLocalizedString(@"Tracks", nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld - %ld", (long)indexPath.section, (long)indexPath.row];
    return cell;
}

@end
