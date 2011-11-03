// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "AssetListVC.h"

@interface AssetListViewControllerTest : ViewControllerWithNavBarTestCase {
    AssetListViewController *vc;
}

- (void)waitUntilDataLoaded;

@end

@implementation AssetListViewControllerTest

- (UIViewController *)createViewController
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    vc = [[[AssetListViewController alloc] initWithNibName:@"AssetListView" bundle:bundle] autorelease];
    return vc;
}

- (void)setUp
{
    [TestCommon installDatabase:@"testdata1"];

    //[self rootViewController];
    
    // AssetView を表示させないようにガードする
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:-1 forKey:@"firstShowAssetIndex"];

    [super setUp]; // ここで rootViewController が生成される
}

- (void)tearDown
{
    [super tearDown];
}

- (void)waitUntilDataLoaded
{
    // AssetListViewController では、データロードは別スレッドで行われる
    // ここでデータロード完了を待つようにする
    // ただし、setUp からは呼べない(ViewController のハンドラがまだ呼ばれていない)
    while (![DataModel instance].isLoadDone) {
        [NSThread sleepForTimeInterval:0.01];
    }
}

- (NSString *)cellText:(int)row section:(int)section
{
    NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:section];
    UITableViewCell *cell = [vc tableView:vc.tableView cellForRowAtIndexPath:index];
    NSLog(@"'%@'", cell.textLabel.text);
    return cell.textLabel.text;
}

- (void)testNormal
{
    NSLog(@"testNormal");

    [self waitUntilDataLoaded];
    
    AssertEqualInt(1, [vc numberOfSectionsInTableView:vc.tableView]);

    // test number of rows
    AssertEqualInt(3, [vc tableView:vc.tableView numberOfRowsInSection:0]);

    // test cell
    AssertEqualObjects(@"Cash : ￥9,000", [self cellText:0 section:0]);
    AssertEqualObjects(@"Bank : ￥195,000", [self cellText:1 section:0]);
    AssertEqualObjects(@"Card : -￥12,100", [self cellText:2 section:0]);
}

@end
