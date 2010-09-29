//
//  RootViewController.m
//  Test
//
//  Created by t on 10/08/15.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"

// publisher ID用のマクロを定義
#import "EdhitaPrivateCommon.h"
// #define kPublisherId @""

@implementation RootViewController

@synthesize detailViewController;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	NSError *error;
	[items_ release];
	items_ = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path_ error:&error] mutableCopy];
	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [items_ count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//        cell.accessoryType = UITableViewCellAccessoryNone;
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    // Configure the cell.
//    cell.textLabel.text = [NSString stringWithFormat:@"Row %d", indexPath.row];
	NSString *text = [items_ objectAtIndex:indexPath.row];
	cell.textLabel.text = text;
	BOOL isDir;
	NSString *path = [path_ stringByAppendingPathComponent:text];
	[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
	cell.imageView.image = [images_ objectAtIndex:isDir];
	
	return cell;


}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Cellが削除された時、ファイルとitemsからも削除する
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		NSString *path = [path_ stringByAppendingPathComponent:[items_ objectAtIndex:indexPath.row]];
		NSError* error;
		
		[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
		
		// 配列からも消さないと落ちる
		[items_ removeObjectAtIndex:indexPath.row];
		
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
/*
	else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
*/
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
     When a row is selected, set the detail view controller's detail item to the item associated with the selected row.
     */
 //   detailViewController.detailItem = [NSString stringWithFormat:@"Row %d", indexPath.row];
	
	NSString *path = [path_ stringByAppendingPathComponent:[items_ objectAtIndex:indexPath.row]];

	BOOL isDir;

	[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];

	// ディレクトリだった場合、そのPathを設定したRootViewControllerを作成
	if (isDir) {		
		RootViewController *rootViewController = [[RootViewController alloc] initWithPath:path];
		// detailはrootがもつ必要ないんじゃ？（navあたりに持たせればいい）
		rootViewController.detailViewController = self.detailViewController;
		[self.navigationController pushViewController:rootViewController animated:YES];
	}
	// ファイルだった場合はDetailに内容を表示
	else {
		detailViewController.path = path;		
	}

	
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [detailViewController release];
	[items_ release];
	[images_ release];
	[path_ release];
    [super dealloc];
}

- (id)initWithPath:(NSString *)path {
	if (self = [super init]) {
		// 与えられたパスの一覧を配列にする
		path_ = [path retain];
		self.title = [path lastPathComponent];

		NSError *error;

		// retainしないとpopoverで開く時に落ちる
		// mutableCopyするとオーナーになるのでretain不要
		items_ = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error] mutableCopy];

		// 画像ボタンを2個作って、それぞれファイル・ディレクトリの作成用のボタンとする
		UIImage* fileImage = [UIImage imageNamed:@"file.png"];
		UIImage* dirImage = [UIImage imageNamed:@"dir.png"];
		images_ = [[NSArray arrayWithObjects:fileImage, dirImage, nil] retain];

		// 右寄せ
		UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

		// 画像＆文字ボタン
//		UIButton *newFileButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//		newFileButton.titleLabel.text = @"NewFile";
//		newFileButton.titleLabel.backgroundColor = [UIColor clearColor];
//		newFileButton.frame = CGRectMake(0, 0, 30, 30);
//		newFileButton.backgroundColor = [UIColor grayColor];
//		[newFileButton setBackgroundImage:[UIImage imageNamed:@"file_new.png"] forState:UIControlStateNormal];
//		[newFileButton addTarget:self action:@selector(newFileDidPush) forControlEvents:UIControlEventTouchUpInside];
		
//		UIBarButtonItem *newFile  = [[UIBarButtonItem alloc] initWithCustomView:newFileButton];
		UIBarButtonItem *newFile  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"file_new.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(newFileDidPush)];
		UIBarButtonItem *newDir  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dir_new.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(newDirDidPush)];

		UIBarButtonItem *ftpButton = [[UIBarButtonItem alloc] initWithTitle:@"FTP" style:UIBarButtonItemStyleBordered target:self action:@selector(ftpDidPush)];
		
		NSArray *items = [NSArray arrayWithObjects:ftpButton, space, newFile, newDir, nil];
		[self setToolbarItems:items];

		// 編集ボタンの表示（selfのeditButtonを設定してやるだけでいい）
		self.navigationItem.rightBarButtonItem = [self editButtonItem];
		
		// 広告領域テスト
//		UIView *adView = [[UIView alloc] init];
//		adView.frame = CGRectMake(0, 0, self.view.frame.size.width, 48);
//		adView.backgroundColor = [UIColor grayColor];
//		self.tableView.tableFooterView = adView;
		
		srand(time(NULL));
		AdMobView *adMobView;
		
		switch (rand() % 2) {
			case 0:
				adMobView = [AdMobView requestAdOfSize:ADMOB_SIZE_320x270 withDelegate:self];				
				break;
			case 1:
				adMobView = [AdMobView requestAdOfSize:ADMOB_SIZE_320x48 withDelegate:self];
				break;
		}
				
		self.tableView.tableFooterView = adMobView;
	}
	return self;
}

// 新しいファイルの作成
- (void)newFileDidPush {
	
	NSError *error;

	// 連番のファイル名を取得
	NSString *fileName = [self nextFileName:@"untitled file"];
	NSString *fileContents = @"";

	NSString *filePath = [path_ stringByAppendingPathComponent:fileName];
	[fileContents writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];

	[items_ addObject:fileName];
	[self.tableView reloadData];
}

// 新しいディレクトリの作成
- (void)newDirDidPush {

	NSError *error;
	
	// 連番のディレクトリ名を取得
	NSString *dirName = [self nextFileName:@"untitled folder"];

	NSString *dirPath = [path_ stringByAppendingPathComponent:dirName];
	[[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:&error];
	
	[items_ addObject:dirName];
	[self.tableView reloadData];
}

- (NSString *)nextFileName:fileName {
	// ちゃんとNSNotFoundと比較しないとうまくうごかん（!とかBOOLでやっちゃダメ）
	if ([items_ indexOfObject:fileName] != NSNotFound) {
		
		int i = 2;		
		NSString *newFileName;
		
		while (i < 1024) {
			newFileName = [fileName stringByAppendingFormat:@" %d", i];
			if([items_ indexOfObject:newFileName] == NSNotFound) {
				return newFileName;
			}
			i++;
		}
	}
	return fileName;
}

// アクセサリボタンがタップされた時はファイル情報表示画面に遷移する
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

	NSString *path = [path_ stringByAppendingPathComponent: [items_ objectAtIndex:indexPath.row]];
	EdhitaTableViewController *tableViewController = [[EdhitaTableViewController alloc] initWithPath:path];
	[self.navigationController pushViewController:tableViewController animated:YES];
	[tableViewController release];	
}

// 勝手にサイズが変わらないようにkeyboad（日本語）表示状態のheightで固定
- (CGSize)contentSizeForViewInPopover {
	return CGSizeMake(320, 527);
}

#pragma mark -
#pragma mark AdMobDelegate methods

- (NSString *)publisherIdForAd:(AdMobView *)adView {
	return kPublisherId; // this should be prefilled; if not, get it from www.admob.com
}

- (UIViewController *)currentViewControllerForAd:(AdMobView *)adView {
	// Return the top level view controller if possible. In this case, it is
	// the split view controller
	return self.splitViewController;
//	return self.navigationController.parentViewController;
}

- (void)willPresentFullScreenModalFromAd:(AdMobView *)adView {
	// IMPORTANT!!! IMPORTANT!!!
	// If we are about to get a full screen modal and we have a popover controller, dimiss it.
	// Otherwise, you may see the popover on top of the landing page.
	if (detailViewController.popoverController && detailViewController.popoverController.popoverVisible) {
		[detailViewController.popoverController dismissPopoverAnimated:YES];
	}
}

- (NSArray *)testDevices {
	return [NSArray arrayWithObjects: ADMOB_SIMULATOR_ID, nil];
}
 
- (void)ftpDidPush {
	[(EdhitaAppDelegate *)[[UIApplication sharedApplication] delegate] rootViewChangesFtp];
}

@end
