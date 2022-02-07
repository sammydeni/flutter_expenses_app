import 'dart:io'; //used for Platform.isIos / Platform.isAndroid...
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './widgets/chart.dart';
import './widgets/new_transaction.dart';
import './widgets/transaction_list.dart';
import './models/transaction.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
              .copyWith(secondary: Colors.orange),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
            onPrimary: Colors.black,
          )),
          textTheme: const TextTheme(
            bodyText2: TextStyle(color: Colors.black),
            headline1: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
            ),
            headline2: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'Quicksand',
            ),
            button: TextStyle(color: Colors.black),
          ),
          appBarTheme: AppBarTheme(
              titleTextStyle: ThemeData.light()
                  .textTheme
                  .copyWith(
                    headline6:
                        const TextStyle(fontFamily: 'OpenSans', fontSize: 16),
                  )
                  .headline6)),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _showChart = false;

  final List<Transaction> _userTransactions = [];

// return a list with only the transactions made within 7 days
  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }

// adds a new transaction to the userTransactions List
  void _addNewTransaction(String txTitle, double txAmount, DateTime txDate) {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: txDate,
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransactions.add(newTx);
    });
  }

// shows a modal to add a new transaction
  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            child: NewTransaction(_addNewTransaction),
            behavior: HitTestBehavior.opaque,
          );
        });
  }

// deletes the transaction with the same id of the argument
  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  List<Widget> _buildLandscapeContent(
      MediaQueryData mQ, AppBar appbar, Widget txListWidget) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Show chart',
            style: Theme.of(context).textTheme.headline1,
          ),
          Switch.adaptive(
              activeColor: Theme.of(context).colorScheme.primary,
              value: _showChart,
              onChanged: (val) {
                setState(() {
                  _showChart = val;
                });
              })
        ],
      ),
      _showChart
          ? SizedBox(
              height: (mQ.size.height -
                      appbar.preferredSize.height -
                      mQ.padding.top) *
                  0.7,
              child: Chart(_recentTransactions),
            )
          : txListWidget
    ];
  }

  List<Widget> _buildPortraitContent(
      MediaQueryData mQ, AppBar appbar, Widget txListWidget) {
    return [
      SizedBox(
        height:
            (mQ.size.height - appbar.preferredSize.height - mQ.padding.top) *
                0.3,
        child: Chart(_recentTransactions),
      ),
      txListWidget
    ];
  }

  Widget _buildIosScaffold(
      Widget pageBody, ObstructingPreferredSizeWidget appbar) {
    return CupertinoPageScaffold(
      child: pageBody,
      navigationBar: appbar,
    );
  }

  Widget _buildAndroidScaffold(Widget pageBody, PreferredSizeWidget appbar) {
    return Scaffold(
      appBar: appbar,
      body: pageBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _startAddNewTransaction(context),
      ),
    );
  }

  Widget _buildAppBar() {
    return Platform.isIOS
        ? CupertinoNavigationBar(
            middle: const Text('Personal Expenses'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              GestureDetector(
                child: const Icon(CupertinoIcons.add),
                onTap: (() => _startAddNewTransaction(context)),
              ),
            ]),
          )
        : AppBar(
            title: const Text('Flutter Expenses App'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _startAddNewTransaction(context),
              )
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context);
    final isLandscape = mQ.orientation == Orientation.landscape;
    final dynamic appbar = _buildAppBar();
    final txListWidget = SizedBox(
        height:
            (mQ.size.height - appbar.preferredSize.height - mQ.padding.top) *
                0.7,
        child: TransactionList(_userTransactions, _deleteTransaction));

    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLandscape)
              ..._buildLandscapeContent(mQ, appbar, txListWidget),
            if (!isLandscape)
              ..._buildPortraitContent(mQ, appbar, txListWidget),
          ],
        ),
      ),
    );

    return Platform.isIOS
        ? _buildIosScaffold(pageBody, appbar)
        : _buildAndroidScaffold(pageBody, appbar);
  }
}
