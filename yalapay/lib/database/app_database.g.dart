// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  BankAccountsDao? _bankAccountDaoInstance;

  BankDao? _bankDaoInstance;

  ChequeStatusDao? _chequeStatusDaoInstance;

  DepositStatusDao? _depositStatusDaoInstance;

  InvoiceStatusDao? _invoiceStatusDaoInstance;

  PaymentModeDao? _paymentModeDaoInstance;

  ReturnReasonDao? _returnReasonDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `bankaccounts` (`accountNo` TEXT NOT NULL, `bank` TEXT NOT NULL, PRIMARY KEY (`accountNo`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `banks` (`bankname` TEXT NOT NULL, PRIMARY KEY (`bankname`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `chequeStatus` (`chequeStatus` TEXT NOT NULL, PRIMARY KEY (`chequeStatus`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `depositStatus` (`depositStatus` TEXT NOT NULL, PRIMARY KEY (`depositStatus`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `invoiceStatus` (`invoiceStatus` TEXT NOT NULL, PRIMARY KEY (`invoiceStatus`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `paymentMode` (`paymentMode` TEXT NOT NULL, PRIMARY KEY (`paymentMode`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `returnReason` (`returnReason` TEXT NOT NULL, PRIMARY KEY (`returnReason`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  BankAccountsDao get bankAccountDao {
    return _bankAccountDaoInstance ??=
        _$BankAccountsDao(database, changeListener);
  }

  @override
  BankDao get bankDao {
    return _bankDaoInstance ??= _$BankDao(database, changeListener);
  }

  @override
  ChequeStatusDao get chequeStatusDao {
    return _chequeStatusDaoInstance ??=
        _$ChequeStatusDao(database, changeListener);
  }

  @override
  DepositStatusDao get depositStatusDao {
    return _depositStatusDaoInstance ??=
        _$DepositStatusDao(database, changeListener);
  }

  @override
  InvoiceStatusDao get invoiceStatusDao {
    return _invoiceStatusDaoInstance ??=
        _$InvoiceStatusDao(database, changeListener);
  }

  @override
  PaymentModeDao get paymentModeDao {
    return _paymentModeDaoInstance ??=
        _$PaymentModeDao(database, changeListener);
  }

  @override
  ReturnReasonDao get returnReasonDao {
    return _returnReasonDaoInstance ??=
        _$ReturnReasonDao(database, changeListener);
  }
}

class _$BankAccountsDao extends BankAccountsDao {
  _$BankAccountsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _bankAccountInsertionAdapter = InsertionAdapter(
            database,
            'bankaccounts',
            (BankAccount item) => <String, Object?>{
                  'accountNo': item.accountNo,
                  'bank': item.bank
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<BankAccount> _bankAccountInsertionAdapter;

  @override
  Future<List<BankAccount>> getBankAccounts() async {
    return _queryAdapter.queryList('SELECT * FROM bankaccounts',
        mapper: (Map<String, Object?> row) => BankAccount(
            accountNo: row['accountNo'] as String,
            bank: row['bank'] as String));
  }

  @override
  Future<int?> getBankAccountCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM bankaccounts',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> addBankAccount(BankAccount bankAccount) async {
    await _bankAccountInsertionAdapter.insert(
        bankAccount, OnConflictStrategy.abort);
  }
}

class _$BankDao extends BankDao {
  _$BankDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _bankInsertionAdapter = InsertionAdapter(database, 'banks',
            (Bank item) => <String, Object?>{'bankname': item.bankName});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Bank> _bankInsertionAdapter;

  @override
  Future<List<Bank>> getBank() async {
    return _queryAdapter.queryList('SELECT * FROM banks',
        mapper: (Map<String, Object?> row) =>
            Bank(bankName: row['bankname'] as String));
  }

  @override
  Future<int?> getBankCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM banks',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> addBank(Bank bank) async {
    await _bankInsertionAdapter.insert(bank, OnConflictStrategy.abort);
  }
}

class _$ChequeStatusDao extends ChequeStatusDao {
  _$ChequeStatusDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _chequeStatusInsertionAdapter = InsertionAdapter(
            database,
            'chequeStatus',
            (ChequeStatus item) =>
                <String, Object?>{'chequeStatus': item.chequeStatus});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ChequeStatus> _chequeStatusInsertionAdapter;

  @override
  Future<List<ChequeStatus>> getChequeStatus() async {
    return _queryAdapter.queryList('SELECT * FROM chequeStatus',
        mapper: (Map<String, Object?> row) =>
            ChequeStatus(chequeStatus: row['chequeStatus'] as String));
  }

  @override
  Future<int?> getChequeStatusCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM chequeStatus',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> addChequeStatus(ChequeStatus chequeStatus) async {
    await _chequeStatusInsertionAdapter.insert(
        chequeStatus, OnConflictStrategy.abort);
  }
}

class _$DepositStatusDao extends DepositStatusDao {
  _$DepositStatusDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _depositStatusInsertionAdapter = InsertionAdapter(
            database,
            'depositStatus',
            (DepositStatus item) =>
                <String, Object?>{'depositStatus': item.depositStatus});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<DepositStatus> _depositStatusInsertionAdapter;

  @override
  Future<List<DepositStatus>> getDepositStatus() async {
    return _queryAdapter.queryList('SELECT * FROM depositStatus',
        mapper: (Map<String, Object?> row) =>
            DepositStatus(depositStatus: row['depositStatus'] as String));
  }

  @override
  Future<int?> getDepositStatusCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM depositStatus',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> addDepositStatus(DepositStatus depositStatus) async {
    await _depositStatusInsertionAdapter.insert(
        depositStatus, OnConflictStrategy.abort);
  }
}

class _$InvoiceStatusDao extends InvoiceStatusDao {
  _$InvoiceStatusDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _invoiceStatusInsertionAdapter = InsertionAdapter(
            database,
            'invoiceStatus',
            (InvoiceStatus item) =>
                <String, Object?>{'invoiceStatus': item.invoiceStatus});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<InvoiceStatus> _invoiceStatusInsertionAdapter;

  @override
  Future<List<InvoiceStatus>> getInvoiceStatus() async {
    return _queryAdapter.queryList('SELECT * FROM invoiceStatus',
        mapper: (Map<String, Object?> row) =>
            InvoiceStatus(invoiceStatus: row['invoiceStatus'] as String));
  }

  @override
  Future<int?> getInvoiceStatusCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM invoiceStatus',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> addInvoiceStatus(InvoiceStatus invoiceStatus) async {
    await _invoiceStatusInsertionAdapter.insert(
        invoiceStatus, OnConflictStrategy.abort);
  }
}

class _$PaymentModeDao extends PaymentModeDao {
  _$PaymentModeDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _paymentModeInsertionAdapter = InsertionAdapter(
            database,
            'paymentMode',
            (PaymentMode item) =>
                <String, Object?>{'paymentMode': item.paymentMode});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PaymentMode> _paymentModeInsertionAdapter;

  @override
  Future<List<PaymentMode>> getPaymentMode() async {
    return _queryAdapter.queryList('SELECT * FROM paymentMode',
        mapper: (Map<String, Object?> row) =>
            PaymentMode(paymentMode: row['paymentMode'] as String));
  }

  @override
  Future<int?> getModesCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM paymentMode',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> addPaymentMode(PaymentMode paymentMode) async {
    await _paymentModeInsertionAdapter.insert(
        paymentMode, OnConflictStrategy.abort);
  }
}

class _$ReturnReasonDao extends ReturnReasonDao {
  _$ReturnReasonDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _returnReasonInsertionAdapter = InsertionAdapter(
            database,
            'returnReason',
            (ReturnReason item) =>
                <String, Object?>{'returnReason': item.returnReason});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ReturnReason> _returnReasonInsertionAdapter;

  @override
  Future<List<ReturnReason>> getReturnReason() async {
    return _queryAdapter.queryList('SELECT * FROM returnReason',
        mapper: (Map<String, Object?> row) =>
            ReturnReason(returnReason: row['returnReason'] as String));
  }

  @override
  Future<int?> getReasonsCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM returnReason',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> addReturnReason(ReturnReason returnReason) async {
    await _returnReasonInsertionAdapter.insert(
        returnReason, OnConflictStrategy.abort);
  }
}
