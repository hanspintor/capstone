import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:paymongo_sdk/paymongo_sdk.dart';
import 'package:proxpress/UI/CustomerUI/top_up_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomerWallet extends StatefulWidget {
  const CustomerWallet({Key key}) : super(key: key);

  @override
  _CustomerWalletState createState() => _CustomerWalletState();
}

class _CustomerWalletState extends State<CustomerWallet> {
  int sampleCustomerWallet = 0;

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    return Center(
      child: Column(
        children: [
          SizedBox(height: 10,),
          Container(
            width: MediaQuery.of(context).size.width * .95,
            height: MediaQuery.of(context).size.height * .30,
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Balance', style: TextStyle(color: Colors.grey),),
                    Text('\₱$sampleCustomerWallet', style: TextStyle(fontSize: 40),), // ${customer.wallet}
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          PageTransition(
                            child: TopUpPage(),
                            type: PageTransitionType.bottomToTop
                          )
                        );
                      },
                      child: Text('+ Top-up'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentOptionList extends StatefulWidget {
  final int amount;

  PaymentOptionList({
    Key key,
    @required this.amount,
  }) : super(key: key);

  @override
  State<PaymentOptionList> createState() => _PaymentOptionListState();
}

class _PaymentOptionListState extends State<PaymentOptionList>
    with PaymongoEventHandler {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            title: Text("Credit/Deibt Payment"),
            onTap: () async {
              await cardPayment(widget.amount);
            },
          ),
          ListTile(
            title: Text("GCash Payment"),
            onTap: () async {
              await gcashPayment(widget.amount);
            },
          ),
          ListTile(
            title: Text("PayMaya Payment"),
            onTap: () async {
              await paymayaPayment(widget.amount);
            },
          ),
        ],
      ),
    );
  }
}

const payMongoKey = String.fromEnvironment('apiKey', defaultValue: 'pk_test_RS1sZidGAsFVdGHszQgTcHCf');
const secretKey = String.fromEnvironment('secretKey', defaultValue: 'sk_test_SULuoYRMZHKvpyMeaRwMcB2v');

mixin PaymongoEventHandler<T extends StatefulWidget> on State<T> {
  final sdk = PayMongoSDK(payMongoKey);
  final secret = PayMongoSDK(secretKey);
  final publicClient = PaymongoClient<PaymongoPublic>(payMongoKey);
  final secretClient = PaymongoClient<PaymongoSecret>(secretKey);
  final billing = PayMongoBilling(
    name: 'Vince',
    email: "vince@gmail.com",
    phone: "09555841041",
    address: PayMongoAddress(
      line1: "test address",
      line2: "test 2 address",
      city: "Cotabato City",
      state: "Maguindanao",
      postalCode: "9600",
      country: "PH",
    ),
  );
  Future<void> cardPayment(int amount) async {
    try {
      final _amount = amount;
      final payment = await publicClient.instance.paymentMethod
          .create(PaymentMethodAttributes(
        billing: billing,
        details: PaymentMethodDetails(
          cardNumber: '4120000000000007',
          expMonth: 2,
          expYear: 27,
          cvc: "123",
        ),
      ));
      final intent = PaymentIntentAttributes(
          amount: _amount.toDouble(),
          description: "Test payment",
          statementDescriptor: "Test payment descriptor",
          metadata: {
            "environment": kReleaseMode ? "LIVE" : "DEV",
          });
      final result =
      await secretClient.instance.paymentIntent.onPaymentListener(
          attributes: intent,
          paymentMethod: payment.id,
          onRedirect: (url) async {
            debugPrint("${url}");
            final res = await Navigator.push<bool>(context,
                CupertinoPageRoute(builder: (context) {
                  return CheckoutPage(
                    url: url,
                    iFrameMode: true,
                  );
                }));
            return res ?? false;
          });
      debugPrint("${result?.status}");
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> paymayaPayment(int amount) async {
    try {
      final _amount = amount;
      final payment = await publicClient.instance.paymentMethod
          .create(PaymentMethodAttributes(
        billing: billing,
        type: PaymentType.paymaya,
        details: PaymentMethodDetails(
          cardNumber: '4120000000000007',
          expMonth: 2,
          expYear: 27,
          cvc: "123",
        ),
      ));
      final intent = PaymentIntentAttributes(
          amount: _amount.toDouble(),
          description: "Test payment",
          statementDescriptor: "Test payment descriptor",
          metadata: {
            "environment": kReleaseMode ? "LIVE" : "DEV",
          });
      const successUrl = 'https://google.com/success';
      final result =
      await secretClient.instance.paymentIntent.onPaymentListener(
          attributes: intent,
          paymentMethod: payment.id,
          returnUrl: successUrl,
          onRedirect: (url) async {
            debugPrint("${url}");
            final res = await Navigator.push<bool>(context,
                CupertinoPageRoute(builder: (context) {
                  return CheckoutPage(
                    url: url,
                    returnUrl: successUrl,
                  );
                }));
            return res ?? false;
          });
      debugPrint("${result?.status}");
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> gcashPayment(int amount) async {
    final _amount = amount;
    final url = 'google.com';
    final _source = SourceAttributes(
      type: "gcash",
      amount: _amount.toDouble(),
      currency: 'PHP',
      redirect: Redirect(
        success: "https://$url/success",
        failed: "https://$url/failed",
      ),
      billing: billing,
    );
    final result = await sdk.createSource(_source);
    final paymentUrl = result.attributes?.redirect.checkoutUrl ?? '';
    final successLink = result.attributes?.redirect.success ?? '';
    if (paymentUrl.isNotEmpty) {
      final response = await Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => CheckoutPage(
            url: paymentUrl,
            returnUrl: successLink,
          ),
        ),
      );
      if (response) {
        final paymentSource =
        PaymentSource(id: result.id ?? '', type: "source");
        final paymentAttr = CreatePaymentAttributes(
          amount: _amount.toDouble(),
          currency: 'PHP',
          description: "test gcash",
          source: paymentSource,
        );
        final createPayment = await secret.createPayment(paymentAttr);
        debugPrint("==============================");
        debugPrint("||${createPayment}||");
        debugPrint("==============================");
      }
    }
  }
}

class CheckoutPage extends StatefulWidget {
  // ignore: public_member_api_docs

  const CheckoutPage({
    @required this.url,
    this.returnUrl,
    this.iFrameMode = false,
  });
  // ignore: public_member_api_docs
  final String url;
  final String returnUrl;
  final bool iFrameMode;
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> with UrlIFrameParser {
  final Completer<WebViewController> _controller = Completer();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, false);
        return false;
      },
      child: Scaffold(
          body: SafeArea(
            child: WebView(
              onWebViewCreated: _controller.complete,
              initialUrl:
              widget.iFrameMode ? toCheckoutURL(widget.url) : widget.url,
              javascriptMode: JavascriptMode.unrestricted,
              debuggingEnabled: kDebugMode,
              navigationDelegate: (request) async {
                if (request.url.contains('success')) {
                  Navigator.pop(context, true);
                  return NavigationDecision.prevent;
                }
                if (request.url.contains('failed')) {
                  Navigator.pop(context, false);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
              javascriptChannels: {
                JavascriptChannel(
                    name: 'Paymongo',
                    onMessageReceived: (JavascriptMessage message) {
                      Navigator.pop(context);
                    }),
              },
              onWebResourceError: (error) async {
                final dialog = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Something went wrong'),
                      content: Text('$error'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text('close'),
                        )
                      ],
                    );
                  },
                );
                if (dialog) {
                  Navigator.pop(context, false);
                }
              },
            ),
          )),
    );
  }
}

mixin UrlIFrameParser<T extends StatefulWidget> on State<T> {
  String toCheckoutURL(String url) {
    return Uri.dataFromString('''
    <html>

<head>
    <style>
        body {
            overflow: hidden
        }

        .embed-paymongo {
            position: relative;
            padding-bottom: 56.25%;
            padding-top: 0px;
            height: 0px;
            overflow: hidden;
        }

        .embed-paymongo iframe,
        .embed-paymongo object,
        .embed-paymongo embed {
            border: 0;
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
        }
    </style>
</head>

<body>

    <iframe style="width:100%;height:100%;top:0;left:0;position:absolute;" frameborder="0" allowfullscreen="1"
        allow="accelerometer;  encrypted-media;" webkitallowfullscreen mozallowfullscreen allowfullscreen
        src="${url}"></iframe>
</body>
<script>
    window.addEventListener('message', ev => {
        Paymongo.postMessage(ev.data);
        return;
    })
</script>

</html>
    
    
    ''', mimeType: 'text/html').toString();
  }
}