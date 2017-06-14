# MKSQLite3

# 目的
>FMDB对SQLite进行了非常好的封装，让开发者易上手，同时也兼顾线程安全问题。但作为ios开发者，还是要明白SQLite的原理和用法。这样至
少可以有助于理解FMDB的封装原理。

# 拓展
>SQLite，是一款轻型的数据库，是遵守ACID的关系型数据库管理系统，它包含在一个相对小的C库中。它是D.RichardHipp建立的公有领域项目。它的设计目标是嵌入式的，
而且目前已经在很多嵌入式产品中使用了它，它占用资源非常的低，在嵌入式设备中，可能只需要几百K的内存就够了。它能够支持Windows/Linux/Unix等等主流的操作系统，同时能够跟很多程序语言相结合，比如 Tcl、C#、PHP、Java等，还有ODBC接口，同样比起Mysql、PostgreSQL这两款开源的世界著名数据库管理系统来讲，它的处理速度比他们都快。

# 抉择
>根据数据量，数据之间的关系，以及对数据的操作，一般优先考虑CoreData。一则好用，二则大部分App的数据量达不到CoreData性能瓶颈。随着ios 设备硬件性能的越来越好，二者在性能上的大部分的时候差别已经不大。
但以下情况，就可以考虑SQLite:1、跨平台。CoreData是不支持的；2、大数据量操作，如10000甚至更多条数据存储，用CoreData来操作的效率是很低的。

# 代码

### 设置SQLite数据库本地存储路径

    -(NSString *)path{
        NSArray * documentArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentPath = [documentArr firstObject];
        NSString * listPath = [NSString stringWithFormat:@"%@/mktest.db",documentPath];
        return listPath;
    }


### 打开数据库，如果在path路径下没有数据库文件，则会自动创建。
    -(void)openDatabase{
        int databaseResult = sqlite3_open([[self path] UTF8String], &_mkDatabase);//0 is success
        if (databaseResult ==SQLITE_OK) {
            self.operateLable.text = @"数据库打开成功！";
        }else
            self.operateLable.text = [NSString stringWithFormat:@"数据库打开失败%d",databaseResult];
    }

### 创建表
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
             self.operateLable.text = [NSString stringWithFormat:@"错误%s",error];
        /*
         创建表失败near "creat": syntax error  如果sql语句存在语法错误，则会返回此信息
         */
    }


### 插入数据

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



### 有条件查询数据
    -(void)search:(sqlite3 *)database{
        sqlite3_stmt * stmt;
        const char * searchSQL = "select id,name,sex from mklist where name = '王wu'";
        int searchResult = sqlite3_prepare_v2(database, searchSQL, -1, &stmt, nil);
        if (searchResult ==SQLITE_OK) {
            while (sqlite3_step(stmt) ==SQLITE_ROW) {
                int idword = sqlite3_column_int(stmt, 0);
                char *nameWord = (char *)sqlite3_column_text(stmt, 1);
                char *sexWord = (char *)sqlite3_column_text(stmt, 2);
            }
        }else
            NSLog(@"预编译失败！");

    }

# 备注
    关于sqlite3_stmt *
    sqlite 操作二进制数据需要用一个辅助的数据类型：sqlite3_stmt * 。
    这个数据类型 记录了一个“sql语句”。为什么我把
    “sql语句” 用双引号引起来？因为你可以把 sqlite3_stmt * 所表示的内容看成是
    sql语句，但是实际上它不是我们所熟知的sql语句。它是一个已经把sql语句解析了的、用sqlite自己标记记录的内部数据结构。
    正因为这个结构已经被解析了，所以你可以往这个语句里插入二进制数据。当然，把二进制数据插到
    sqlite3_stmt 结构里可不能直接 memcpy ，也不能像 std::string 那样用 + 号。必须用 sqlite 提供的函数来插入。


# 总结
##### 以上是关于SQLite3的基本使用，对于熟悉SQL查询语句的朋友来说，应该用着很亲切。整体上来说，SQLite使用还是非常让人舒适，特别是那如白话般的查询语句。
这里对SQLite进行说明，主要是为了加深对SQLite的理解，另外，SQLite是线程不安全的，多线程操作同一个数据库会产生数据混乱的结果。因此，真正在实践中，首推FMDB。















