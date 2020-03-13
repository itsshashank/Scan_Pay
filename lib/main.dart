import 'dart:async';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ));

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return new HomePageState();
  }
}

String amount="";

class HomePageState extends State<HomePage> {
  String result = "Welcome !";
  String blabel = "Scan";
  IconData i = Icons.camera_alt;
  // String dis = "Rs.";
  Future _scanQR() async {
   
    try {
      String qrResult = await BarcodeScanner.scan();
      setState(() {
        // result ="Rs."+qrResult;
        amount = qrResult;
        i = Icons.account_balance_wallet;
        blabel = "Pay now";
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
        blabel = "Scan Again";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan and Pay"),
      ),
      body: Center(
        child: Text(
          result,
          style: new TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton:FloatingActionButton.extended(
        icon: Icon(i),
        
        label: Text(blabel),
        onPressed: blabel == "Scan"? _scanQR: {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PayScreen(),))
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class PayScreen extends StatefulWidget{
  
  @override
  PayScreenState createState() => new PayScreenState();
}
class PayScreenState extends State<PayScreen>{
 Razorpay _razorpay;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Scan_Pay'),
        ),
        body: 
        Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Rs."+amount,style: new TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
                  RaisedButton(onPressed: openCheckout, child: Text('pay now')),
                  // RaisedButton(onPressed: back ,child: Text("Back"),)
            ]
            )
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void back()
  {
    Navigator.of(context).pop();
  }
  void openCheckout() async {
    var a = int.parse(amount);
    print(a);
    var options = {
      'key': 'rzp_test_AFrQhfmGP7iSC9',
      'amount': a*100,
      'name': 'Current Corp.',
      'description': 'Current used',
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId, timeInSecForIos: 4);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message,
        timeInSecForIos: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName, timeInSecForIos: 4);
  }

}