//
//  JSWSimpleJSONTable.m
//  JSWSimpleJSONTable
//
//  Created by James Stuckey Weber on 1/2/13.
//  Copyright (c) 2013 James Stuckey Weber. All rights reserved.
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "JSWSimpleJSONTable.h"
#import "AFJSONRequestOperation.h"


@implementation JSWSimpleJSONTable

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithStyle:(UITableViewStyle)style file:(NSString *)file delegate:(JSWSimpleJSONTable *)delegate{
	self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		NSError *error;
		NSString *textPath = [[NSBundle mainBundle] pathForResource:file ofType:@"json"];
		NSData *data = [NSData dataWithContentsOfFile:textPath options:NSDataReadingMapped error:&error];
		if(error != nil)
			NSLog(@"Error: %@", error);
		_data = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		if(error != nil)
			NSLog(@"Error: %@", error);
		_delegate = delegate;
        [self.tableView reloadData];
    }
    return self;
}

-(id)initWithStyle:(UITableViewStyle)style url:(NSURL *)url delegate:(JSWSimpleJSONTable *)delegate{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            _data = JSON;
            [self.tableView reloadData];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSURL * url2 = [url URLByDeletingPathExtension];
            NSString *file = [url2 lastPathComponent];
            id newSelf = [self initWithStyle:style file:file delegate:delegate];
            newSelf = nil;
        }];
        [operation start];
        
		_delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_data count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSDictionary *dict = (NSDictionary *)[_data objectAtIndex:section];
	NSDictionary *rows = [dict objectForKey:@"rows"];
	return rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	if (cell == nil) {
		
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    }
	NSDictionary *section = [_data objectAtIndex:indexPath.section];
	NSArray *rows = [section objectForKey:@"rows"];
	NSDictionary *row = [rows objectAtIndex:indexPath.row];
	cell.textLabel.text = [row objectForKey:@"text"];
	[cell.imageView setImage:[UIImage imageNamed:[row objectForKey:@"image"]]];
	cell.detailTextLabel.text = [row objectForKey:@"detailText"];
    
    cell.textLabel.numberOfLines = 0;
	cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	
	cell.detailTextLabel.numberOfLines = 0;
	cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
	
	//Set Accessory
	id accessoryID = [row objectForKey:@"accessory"];
	if(accessoryID == nil){
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else {
		cell.accessoryType = [self accessoryFromString:(NSString *)accessoryID];
	}
	
	//Disable user interaction if no action
	id actionID = [row objectForKey:@"action"];
	if(actionID == nil)
		cell.userInteractionEnabled = NO;
	
    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	NSDictionary *sectionDict = [_data objectAtIndex:section];
	if([sectionDict objectForKey:@"text"] != nil)
		return [sectionDict objectForKey:@"text"];
	else return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSDictionary *section = [_data objectAtIndex:indexPath.section];
	NSArray *rows = [section objectForKey:@"rows"];
	NSDictionary *row = [rows objectAtIndex:indexPath.row];
	id heightID = [row objectForKey:@"height"];
	CGFloat height;
	if (heightID == nil) {
		height = 44;
	} else if([(NSString *)heightID isEqualToString:@"auto"]){
		
		CGSize labelsize,detailsize;
		CGFloat labelWidth = self.view.frame.size.width-40;
		NSDictionary *section = [_data objectAtIndex:indexPath.section];
		NSArray *rows = [section objectForKey:@"rows"];
		NSDictionary *row = [rows objectAtIndex:indexPath.row];
		
		UILabel * textDesc1 = [[UILabel alloc] init];
		[textDesc1 setNumberOfLines:0];
		textDesc1.text=[row objectForKey:@"text"];
		[textDesc1 setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
		labelsize=[textDesc1.text sizeWithFont:textDesc1.font constrainedToSize:CGSizeMake(labelWidth, 2000.0) lineBreakMode:NSLineBreakByWordWrapping];
		
		UILabel * textDesc2 = [[UILabel alloc] init];
		[textDesc2 setNumberOfLines:0];
		textDesc2.text=[row objectForKey:@"detailText"];
		[textDesc2 setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
		detailsize=[textDesc2.text sizeWithFont:textDesc2.font constrainedToSize:CGSizeMake(labelWidth, 2000.0) lineBreakMode:NSLineBreakByWordWrapping];
		
		height = labelsize.height + detailsize.height +20;
	}
	else {
		height = [heightID floatValue];
	}
	return height;
	
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	NSDictionary *sectionDict = [_data objectAtIndex:section];
	id heightID = [sectionDict objectForKey:@"height"];
	NSString *text = [sectionDict objectForKey:@"text"];
	CGFloat height;
	if (text == nil) {
		height = 0;
	} else {
		if(heightID == nil)
			height = [heightID floatValue];
		else
			height = 30;
	}
	return height;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *section = [_data objectAtIndex:indexPath.section];
	NSArray *rows = [section objectForKey:@"rows"];
	NSDictionary *row = [rows objectAtIndex:indexPath.row];
	NSString *actionName = [row objectForKey:@"action"];
	SEL selector = sel_registerName([actionName cStringUsingEncoding:NSStringEncodingConversionExternalRepresentation]);
	if([_delegate respondsToSelector:selector]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[_delegate performSelector:selector];
#pragma clang diagnostic pop
		}
	
	NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
	if (selection){
		[self.tableView deselectRowAtIndexPath:selection animated:YES];
	}
	
}

#pragma mark Helper Functions
- (NSUInteger) accessoryFromString: (NSString*) s{
	NSArray *enumArray =  @[@"UITableViewCellAccessoryNone", @"UITableViewCellAccessoryDisclosureIndicator", @"UITableViewCellAccessoryDetailDisclosureButton", @"UITableViewCellAccessoryCheckmark"];
    NSUInteger n = [enumArray indexOfObject:s];
    if ( n == NSNotFound ) {
        n = 0;
    }
    return n;
}
@end