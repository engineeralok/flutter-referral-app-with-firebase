import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_referral_app/enums/state.dart';

class RefProvider extends ChangeNotifier {
  ViewState state = ViewState.Idle;

  String message = "";

  CollectionReference profileRef =
      FirebaseFirestore.instance.collection('users');

  FirebaseAuth auth = FirebaseAuth.instance;

  setReferral(String refCode) async {
    try {
      state = ViewState.Busy;
      notifyListeners();

      final value = await profileRef.where("refCode", isEqualTo: refCode).get();

      if (value.docs.isEmpty) {
        ///Ref code is not available
        message = "Invalid Referral Code";
        state = ViewState.Error;
        notifyListeners();
      } else {
        ///Ref code is available
        final data = value.docs[0];

        //Getting refferals
        List referrals = data.get("referrals");
        referrals.add(auth.currentUser!.email);

        //updating the ref earning
        final body = {
          "referrals": referrals,
          "refEarnings": data.get("refEarnings") + 500,
        };

        await profileRef.doc(data.id).update(body);
        message = "Referral code applied successfully";
        state = ViewState.Success;
        notifyListeners();
      }
    } on FirebaseException catch (e) {
      message = e.message.toString();
      state = ViewState.Error;
      notifyListeners();
    } catch (e) {
      message = e.toString();
      state = ViewState.Error;
      notifyListeners();
    }
  }
}
