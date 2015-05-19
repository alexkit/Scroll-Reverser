//
//  Logger.m
//  ScrollReverser
//
//  Created by Nicholas Moore on 07/05/2015.
//
//

#import "Logger.h"

NSString *const LoggerEntriesChanged=@"LoggerEntriesChanged";
NSString *const LoggerMaxLines=@"LoggerMaxLines";

@interface Logger ()
@property NSMutableArray *logArray;
@property NSDateFormatter *df;
@end

@implementation Logger

- (id)init
{
    self=[super init];
    if (self) {
        self.logArray=[NSMutableArray array];
        self.limit=[[NSUserDefaults standardUserDefaults] integerForKey:LoggerMaxLines];
        self.enabled=YES;
        self.df=[[NSDateFormatter alloc] init];
        self.df.dateFormat=@"yyyy-MM-dd HH:mm:ss";
    }
    return self;
}

- (void)append:(NSString *)str color:(NSColor *)color
{
    NSString *const rawDateString=[NSString stringWithFormat:@"%@ ", [self.df stringFromDate:[NSDate date]]];
    NSDictionary *const dateAttributes=@{NSForegroundColorAttributeName: [NSColor grayColor]};
    NSDictionary *const logAttributes=color?@{NSForegroundColorAttributeName: color}:@{};

    // build string to log
    NSMutableAttributedString *const logString=[[[NSAttributedString alloc] initWithString:rawDateString
                                                                                attributes:dateAttributes] mutableCopy];
    [logString appendAttributedString:[[NSAttributedString alloc] initWithString:str
                                                                   attributes:logAttributes]];
    
    [self.logArray addObject:logString];
    while (self.limit>0&&[self.logArray count]>self.limit) {
        [self.logArray removeObjectAtIndex:0];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:LoggerEntriesChanged object:self];
}

- (void)clear
{
    [self.logArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:LoggerEntriesChanged object:self];
}

- (void)logString:(NSString *)str color:(NSColor *)color force:(BOOL)force
{
    if ((force||self.enabled) && [str isKindOfClass:[NSString class]])  {
        [self append:[str stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] color:color];
    }
}

- (void)logString:(NSString *)str color:(NSColor *)color
{
    [self logString:str color:color force:NO];
}

- (void)logString:(NSString *)str
{
    [self logString:str color:nil force:NO];
}

- (NSUInteger)entryCount
{
    return self.logArray.count;
}

- (NSAttributedString *)entryAtIndex:(NSUInteger)row
{
    if (row<self.logArray.count) {
        return self.logArray[row];
    }
    else {
        return nil;
    }
}

@end
