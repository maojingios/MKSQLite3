
/*
 1、ACID，是指在可靠数据库管理系统（DBMS）中，事务(transaction)所应该具有的四个特性：原子性（Atomicity）、一致性（Consistency）、隔离性（Isolation）、持久性（Durability）.这是可靠数据库所应具备的几个特性.
 
 */


#import "ViewController.h"
#import <sqlite3.h>

@interface ViewController ()
{
   sqlite3 * _mkDatabase;
}
@property (strong, nonatomic) IBOutlet UITextView *operateLable;
@property (strong, nonatomic) IBOutlet UITextField *insertNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *insertSexTextField;
@property (strong, nonatomic) IBOutlet UITextField *modifyOriginNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *modifyNewNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *deleteName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self.operateLable resignFirstResponder];
    [self.insertNameTextField resignFirstResponder];
    [self.insertSexTextField resignFirstResponder];
    [self.modifyOriginNameTextField resignFirstResponder];
    [self.modifyNewNameTextField resignFirstResponder];
}

/*
 创建、打开数据库
 */
- (IBAction)creatOpenDatabase:(UIButton *)sender {
    [self openDatabase];
}
/*
 创建表
 */
- (IBAction)creatTable:(UIButton *)sender {
    [self creatTable];
    
}
/*
 插入数据
*/
- (IBAction)insertData:(UIButton *)sender {
    [self insert];
}

/*
 修改数据
 */
- (IBAction)modifyData:(id)sender {
    
    [self modify];
}
/*
 删除数据
 */
- (IBAction)deleteData:(UIButton *)sender {
}

/*
 路径
 */
-(NSString *)path{
    NSArray * documentArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentPath = [documentArr firstObject];
    NSString * listPath = [NSString stringWithFormat:@"%@/mktest.db",documentPath];
    return listPath;
}


-(void)openDatabase{
    
    int databaseResult = sqlite3_open([[self path] UTF8String], &_mkDatabase);//0 is success
    if (databaseResult ==SQLITE_OK) {
        
        self.operateLable.text = @"数据库打开成功！";
        
    }else
        self.operateLable.text = [NSString stringWithFormat:@"预编译错误%d",databaseResult];
}
-(void)creatTable {
    char * error;
    const char * creatSQL = "create table if not exists mklist(id integer primary key autoincrement,name char,sex char)";
    /*
     sqlite3 *         sqlite3实例对象
     const char *sql   创建表语句
     int (*callback)(void *, int, char **, char **) 回调
     char **errmsg      错误信息
     */
    int tableResult = sqlite3_exec(_mkDatabase, creatSQL,NULL, NULL, &error);
    if (tableResult ==SQLITE_OK) {
        
        self.operateLable.text = @"建表成功！";
        
    }else
         self.operateLable.text = [NSString stringWithFormat:@"预编译错误%s",error];
    
    /*
     创建表失败near "creat": syntax error  如果sql语句存在语法错误，则会返回此信息
     */
}

/*
 sqlite 操作二进制数据需要用一个辅助的数据类型：sqlite3_stmt * 。
 这个数据类型 记录了一个“sql语句”。为什么我把
 “sql语句” 用双引号引起来？因为你可以把 sqlite3_stmt * 所表示的内容看成是
 sql语句，但是实际上它不是我们所熟知的sql语句。它是一个已经把sql语句解析了的、用sqlite自己标记记录的内部数据结构。
 正因为这个结构已经被解析了，所以你可以往这个语句里插入二进制数据。当然，把二进制数据插到
 sqlite3_stmt 结构里可不能直接 memcpy ，也不能像 std::string 那样用 + 号。必须用 sqlite 提供的函数来插入
 
   1、【插入数据】在这里我们使用绑定数据的方法，参数一：sqlite3_stmt，参数二：插入列号，参数三：插入的数据，参数四：数据长度（-1代表全部），参数五：是否需要回调
 sqlite3_bind_text(stmt, 1, [self.nameTextField.text UTF8String], -1, NULL);
 sqlite3_bind_int(stmt, 2, [self.ageTextField.text intValue]);
 sqlite3_bind_text(stmt, 3, [self.sexTextField.text UTF8String], -1, NULL);
 sqlite3_bind_int(stmt, 4, [self.weightTextField.text integerValue]);
 sqlite3_bind_text(stmt, 5, [self.addressTextField.text UTF8String], -1, NULL);
 
 2、直接把数据写在要执行的sql语句后面，如下：
 [cpp] view plain copy
 NSString *insert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO PERSIONINFO('%@','%@','%@','%@','%@')VALUES('%@','%d','%@','%d','%@')",NAME,AGE,SEX,WEIGHT,ADDRESS,@"小杨",23,@"man",65,@"中国北京,haidian,shangdi,xinxiRoad,100014"];
 */

-(void)insert{
    
    /*
     sqlite3 *db         数据库实例对象
     const char *zSql    sq语句
     int nByte           sq语句最大长度
     sqlite3_stmt **ppStmt 详见上面解释
     const char **pzTail   指向sq语句未使用部分
     */
    const char * insertName = [self.insertNameTextField.text UTF8String];
    const char * insertSex = [self.insertSexTextField.text UTF8String];
    
    sqlite3_stmt * stmt;
    const char * insertSQL = "insert into mklist (name,sex)values(?,?)";
    int insertResult = sqlite3_prepare_v2(_mkDatabase, insertSQL, -1, &stmt, nil);
    
    if (insertResult ==SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, insertName, -1, NULL);
        sqlite3_bind_text(stmt, 2, insertSex, -1, NULL);
        
        sqlite3_step(stmt);
        
        self.operateLable.text = @"插入成功！";
        
        [self reloadData];
        
    }else
        self.operateLable.text = @"预编译错误";
}

/*
 有条件查询数据
 */

-(void)search:(sqlite3 *)database{

    sqlite3_stmt * stmt;
    const char * searchSQL = "select id,name,sex from mklist where name = '王wu'";
    int searchResult = sqlite3_prepare_v2(database, searchSQL, -1, &stmt, nil);
    if (searchResult ==SQLITE_OK) {
        
        NSLog(@"%d",sqlite3_step(stmt));
        
        while (sqlite3_step(stmt) ==SQLITE_ROW) {
            
            int idword = sqlite3_column_int(stmt, 0);
            char *nameWord = (char *)sqlite3_column_text(stmt, 1);
            char *sexWord = (char *)sqlite3_column_text(stmt, 2);
            
            NSLog(@"id=%d\nname=%s\nsex=%s",idword,nameWord,sexWord);
        }

        
    }else
        NSLog(@"查询失败！");
    
}

-(void)modify{
    
//    NSString * modifyString = [NSString stringWithFormat:@"update mklist set name = '%@' where ID = '%d'",self.modifyOriginNameTextField.text,[self.modifyNewNameTextField.text intValue]];

    sqlite3_stmt * stmt;//update haha set name = 'buhao' where name = 'iosRunner'
    
    
    const char * modifySQL = "update mklist set name = ? where ID = ?";
    int modifyResult = sqlite3_prepare_v2(_mkDatabase, modifySQL, -1, &stmt, nil);
    
    if (modifyResult ==SQLITE_OK) {
        sqlite3_bind_text(stmt, 1,[self.modifyOriginNameTextField.text UTF8String], -1, nil);
        sqlite3_bind_int(stmt, 0, [self.modifyNewNameTextField.text intValue]);
        sqlite3_step(stmt);
        
        [self reloadData];
        
    }else
        NSLog(@"修改--预编译失败！");
    
}
-(void)reloadData{
    
    NSMutableArray * mutableArray = [NSMutableArray array];

    sqlite3_stmt * stmt;//数据库操作指针
    const char * searchSQL = "select * from mklist";
    int searchResult = sqlite3_prepare_v2(_mkDatabase, searchSQL, -1, &stmt, NULL);
    if (searchResult ==SQLITE_OK) {
        
        while (sqlite3_step(stmt) ==SQLITE_ROW) {//查到数据
            
            NSMutableArray * mutableArrayTemp = [NSMutableArray array];
            
            int idword = sqlite3_column_int(stmt, 0);
            char *nameWord = (char *)sqlite3_column_text(stmt, 1);
            char *sexWord = (char *)sqlite3_column_text(stmt, 2);
            
            NSString * idstring = [NSString stringWithFormat:@"ID=%d",idword];
            NSString * namestring = [NSString stringWithFormat:@"name=%@",[NSString stringWithUTF8String:nameWord]];
            NSString * sexstring = [NSString stringWithFormat:@"sex=%@",[NSString stringWithUTF8String:sexWord]];
            
            [mutableArrayTemp addObjectsFromArray:@[idstring,namestring,sexstring]];
            [mutableArray addObject:mutableArrayTemp];
            
        }
        NSString * allString = @"";
        if (mutableArray.count>0) {
            for (NSArray * arr in mutableArray) {
                NSString * string = [arr componentsJoinedByString:@""];
                allString = [allString stringByAppendingString:[NSString stringWithFormat:@"\n%@",string]];
            }
            self.operateLable.text = allString;
        }
    }
    else
        self.operateLable.text = @"查询所有信息--校验SQL语句失败！";
}

@end
