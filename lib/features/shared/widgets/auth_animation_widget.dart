import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart';

class AuthAnimationWidget extends StatefulWidget {
  const AuthAnimationWidget({super.key});

  @override
  State<AuthAnimationWidget> createState() => AuthAnimationWidgetState();
}

class AuthAnimationWidgetState extends State<AuthAnimationWidget> {
  Artboard? _artboard;
  SimpleAnimation? _idleCtrl;
  OneShotAnimation? _oneShotCtrl;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  Future<void> _loadRiveFile() async {
    await RiveFile.initialize();
    final data = await rootBundle.load('assets/animations/click_for_hat.riv');
    final file = RiveFile.import(data);
    final artboard = file.mainArtboard;

    _idleCtrl = SimpleAnimation('Idle', autoplay: true);
    artboard.addController(_idleCtrl!);

    setState(() => _artboard = artboard);
  }

  void playHat() {
    if (_artboard == null) return;

    _oneShotCtrl?.isActive = false;
    _idleCtrl?.isActive = false;
    _oneShotCtrl = OneShotAnimation('React1', autoplay: true, onStop: () {
      _oneShotCtrl = OneShotAnimation(
        'SwitchHat',
        autoplay: true,
        onStop: () {
          _oneShotCtrl = OneShotAnimation(
            'MouthSmile',
            autoplay: true,
            onStop: () {
              _oneShotCtrl = OneShotAnimation(
                'MouthOh',
                autoplay: true,
                onStop: () {
                  _idleCtrl = SimpleAnimation('Idle', autoplay: true);
                  _artboard!.addController(_idleCtrl!);
                },
              );
              _artboard!.addController(_oneShotCtrl!);
            },
          );
          _artboard!.addController(_oneShotCtrl!);
        },
      );
      _artboard!.addController(_oneShotCtrl!);
    });

    _artboard!.addController(_oneShotCtrl!);
  }

  void removeHat() {
    if (_artboard == null) return;

    _oneShotCtrl?.isActive = false;
    _idleCtrl?.isActive = false;
    _oneShotCtrl = OneShotAnimation(
      'React1',
      autoplay: true,
      onStop: () {
        _oneShotCtrl = OneShotAnimation(
          'SwitchHat',
          autoplay: true,
          onStop: () {
            _oneShotCtrl = OneShotAnimation(
              'MouthGrin',
              autoplay: true,
              onStop: () {
                _oneShotCtrl = OneShotAnimation(
                  'MouthSmile',
                  autoplay: true,
                  onStop: () {
                    _idleCtrl = SimpleAnimation('Idle', autoplay: true);
                    _artboard!.addController(_idleCtrl!);
                  },
                );
                _artboard!.addController(_oneShotCtrl!);
              },
            );
            _artboard!.addController(_oneShotCtrl!);
          },
        );
        _artboard!.addController(_oneShotCtrl!);
      },
    );

    _artboard!.addController(_oneShotCtrl!);
  }

@override
Widget build(BuildContext context) {
  return ClipOval(
    child: SizedBox(
      width: 200,
      height: 200,
      child: _artboard == null
          ? const SizedBox()
          : _buildTranslatedRive(), 
    ),
  );
}

Widget _buildTranslatedRive() {
  return Stack(
    clipBehavior: Clip.none, // para permitir que el Rive “sobresalga” un poco
    children: [
      Positioned(
        left: -29,
        top: -29,
        width: 257,
        height: 257,
        child: Rive(artboard: _artboard!),
      ),
    ],
  );
}

}
