import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/page/sign-up/sign-up.notifier.dart';
import 'package:fitnc_user/widget/bottom.widget.dart';
import 'package:fitnc_user/constants.dart';
import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/service/display.service.dart';
import 'package:flutter/material.dart';

import 'package:fitnc_user/page/sign-up/sign-up-desktop.page.dart';
import 'package:fitnc_user/page/sign-up/sign-up-mobile.page.dart';

typedef CallbackUserCredential = void Function(UserCredential userCredential);

///
/// La page possède le notifier du formulaire : elle le crée, le libère, et
/// c'est elle qui déclenche le callback de navigation.
///
class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key, this.callback}) : super(key: key);

  final CallbackUserCredential? callback;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final SignUpNotifier notifier = SignUpNotifier();
  final DisplayTypeService displayTypeService = di<DisplayTypeService>();

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  Future<void> _submit(GlobalKey<FormState> formKey) async {
    final UserCredential? credential = await notifier.validateSignUp(formKey);
    if (credential != null && mounted) {
      widget.callback?.call(credential);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              left: 0,
              child: Hero(
                tag: 'IMAGE_ASSET',
                child: ValueListenableBuilder<DisplayType>(
                  valueListenable: displayTypeService.displayType,
                  builder: (_, DisplayType type, __) {
                    String size = (type == DisplayType.mobile)
                        ? 'S'
                        : (type == DisplayType.tablet)
                            ? 'M'
                            : 'L';
                    return Image.asset(
                      '${FitnessConstants.imageLogin}-$size${FitnessConstants.imageLoginExtension}',
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            ValueListenableBuilder<DisplayType>(
              valueListenable: displayTypeService.displayType,
              builder: (_, DisplayType type, __) {
                if (type == DisplayType.desktop) {
                  return SignUpDesktopPage(
                      notifier: notifier, onSubmit: _submit);
                }
                return SignUpMobilePage(
                    notifier: notifier, onSubmit: _submit);
              },
            ),
            const Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: BottomCu(),
            ),
          ],
        ),
      ),
    );
  }
}
