//
//  ViewController.m
//  IPScanner
//
//  Created by pramesh on 2/7/14.
//  Copyright (c) 2014 pramesh. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController{
    NSString *str;
    int rowNumber;
}
@synthesize myTableView, btnScan, btnScanComputer;

- (void)viewDidLoad
{
    [super viewDidLoad];
	arrBarcode = [[NSMutableArray alloc]init];
    
    // Set background image
    UIImageView *img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"color_bg.png"]];
    [self.view addSubview:img];
    [self.view sendSubviewToBack:img];

    // Display btnScan
    UIImage * imgScan = [UIImage imageNamed:@"button_active.png"];
    [btnScan setBackgroundImage:imgScan forState:UIControlStateNormal];
    [btnScan setTitle:@"Scan" forState:UIControlStateNormal];
    
    // Display Scan Computer Button
    UIImage *imgScanComputer = [UIImage imageNamed:@"button_active.png"];
    [btnScanComputer setBackgroundImage:imgScanComputer forState:UIControlStateNormal];
    [btnScanComputer setTitle:@"Scan Computer" forState:UIControlStateNormal];

}

// UITableView Delegate Methods
-(NSInteger)numberOfSectionsInTableView: (UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrBarcode count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell Identifier";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *barcode = [arrBarcode objectAtIndex:[indexPath row]];
    // Create custom color
    UIColor *color = [UIColor colorWithRed:0/255.0f green:150/255.0f blue:225/255.0f alpha:1.0f];
    cell.textLabel.textColor = color;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];    [cell.textLabel setText:barcode];
    [cell setBackgroundColor:[UIColor clearColor]];
    //UIButton *btn = [[UIButton alloc]init];
    //btn.frame = CGRectMake(200, 5.0, 50, 30);
    //btn.backgroundColor = [UIColor blackColor];
    //[btn setTitle:@"Send" forState:UIControlStateNormal];
    //[cell addSubview:btn];
    return cell;
}

// Set the identation for rows in UITableView
-(NSInteger) tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 5;
}

// Set the scroll in UITableView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = 10;
    if (y > h + reload_distance)
    {
        [self.myTableView reloadData];
    }
}

// Set the cell click
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    rowNumber = indexPath.row;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    str = cell.textLabel.text;
}

// Delete the data in each cell in UITableView
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [arrBarcode removeObjectAtIndex:indexPath.row];
        [self.myTableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)btnScan:(id)sender {
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    ZBarImageScanner *scanner = reader.scanner;
    [scanner    setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    [self presentViewController:reader animated:YES completion:nil];
}

- (IBAction)btnScanComputer:(id)sender {
    ZBarReaderController *reeader = [ZBarReaderController new];
    reeader.readerDelegate = self;
    if ([ZBarReaderController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        reeader.sourceType = UIImagePickerControllerSourceTypeCamera;
    [reeader.scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    [self presentViewController:reeader animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)reeader didFinishPickingMediaWithInfo:(NSDictionary *)info{
    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for (symbol in results)
        break;
    //txtScannedBarcode.text = symbol.data;
    //str = txtScannedBarcode.text;
    str = symbol.data;
    if (symbol.data != nil){
        [arrBarcode addObject:str];
    }
    //resultImage.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.myTableView reloadData];
    [reeader dismissViewControllerAnimated:YES completion:nil];
}

@end
