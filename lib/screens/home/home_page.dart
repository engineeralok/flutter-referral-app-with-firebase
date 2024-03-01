import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_referral_app/screens/authentication/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final auth = FirebaseAuth.instance;

  _buildCardListTile(earnings, refCode) {
    return Column(
      children: [
        Card(
          child: ListTile(
            title: const Text("Earnings"),
            subtitle: Text("Rs. $earnings/-"),
          ),
        ),
        const Divider(thickness: 1),
        Card(
          child: ListTile(
            title: const Text("Referral Code"),
            subtitle: Text("$refCode"),
            trailing: IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: refCode));

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Referal Code Copied"),
                  ),
                );
              },
              icon: const Icon(Icons.copy),
            ),
          ),
        ),
      ],
    );
  }

  _buildInviteMessage(refCode) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Invite Your Friends To Our App And Earn Rs. 500/-. When They Register With Your Referal Code($refCode)",
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Share Link"),
          )
        ],
      ),
    );
  }

  _buildTotalReferrals(List referralList) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Refferals"),
              Text("${referralList.length}"),
            ],
          ),
        ),
        referralList.isEmpty
            ? const Center(
                child: Text("No Referrals"),
              )
            : const Divider(thickness: 1),
        ...List.generate(referralList.length, (index) {
          final data = referralList[index];
          return Container(
            height: 50,
            margin: const EdgeInsets.only(
              bottom: 10,
            ),
            child: ListTile(
              leading: CircleAvatar(
                child: Text("${index + 1}"),
              ),
              title: Text("$data"),
            ),
          );
        })
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference profileRef =
        FirebaseFirestore.instance.collection("users");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
              onPressed: () {
                auth.signOut().then((value) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const LoginPage()),
                      (route) => false);
                });
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
          future: profileRef
              .where("refCode", isEqualTo: auth.currentUser!.uid)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final data = snapshot.data!.docs[0];
            final earnings = data.get("refEarnings");
            List referralList = data.get("referrals");

            final refCode = data.get("refCode");
            return Container(
              padding: const EdgeInsets.all(10),
              child: RefreshIndicator(
                onRefresh: () {
                  setState(() {});
                  return Future.delayed(const Duration(seconds: 2));
                },
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                        child: Column(
                      children: [
                        _buildCardListTile(earnings, refCode),
                        const Divider(thickness: 1),
                        _buildInviteMessage(refCode),
                        const Divider(thickness: 1),
                        _buildTotalReferrals(referralList),
                      ],
                    )),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
