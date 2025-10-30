
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_manager/providers/app_provider.dart';
import 'package:money_manager/screens/currency_selection_screen.dart';
import 'package:money_manager/widgets/language_tile.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final bool isInitialSetup;

  const LanguageSelectionScreen({super.key, this.isInitialSetup = false});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with TickerProviderStateMixin {
  String? _selectedLanguageCode;
  final Map<String, GlobalKey> _tileKeys = {};
  final GlobalKey _appBarActionKey = GlobalKey();

  final Map<String, Map<String, String>> _languages = {
    'en': {'name': 'English', 'icon': '🇬🇧'},
    'vi': {'name': 'Tiếng Việt', 'icon': '🇻🇳'},
    'fr': {'name': 'Français', 'icon': '🇫🇷'},
    'zh_CN': {'name': '中文 (简体)', 'icon': '🇨🇳'},
    'zh_TW': {'name': '中文 (繁體)', 'icon': '🇨🇳'},
    'hi': {'name': 'हिन्दी', 'icon': '🇮🇳'},
    'es': {'name': 'Español', 'icon': '🇪🇸'},
    'pt_BR': {'name': 'Português (Brasil)', 'icon': '🇧🇷'},
  };

  AnimationController? _animationController;
  Animation<Offset>? _animation;
  Offset? _initialIconOffset; // Position for the initial icon over 'English'

  bool _isAnimating = false;
  bool _selectionMade = false; // To track if a selection has occurred

  @override
  void initState() {
    super.initState();
    // Per user request, do not pre-select a language.
    // _selectedLanguageCode =
    //     Provider.of<AppProvider>(context, listen: false).locale?.languageCode;

    for (var code in _languages.keys) {
      _tileKeys[code] = GlobalKey();
    }

    // After the first frame, get the position of the 'English' tile for the initial icon placement.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final RenderBox? englishBox = _tileKeys['en']?.currentContext?.findRenderObject() as RenderBox?;
        if (englishBox != null) {
          setState(() {
            _initialIconOffset = englishBox.localToGlobal(englishBox.size.center(Offset.zero));
          });
        }
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false; // Animation is done
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _onLanguageSelected(String languageCode) {
    if (_isAnimating) return; // Prevent selection during animation

    setState(() {
      _selectedLanguageCode = languageCode;
      _selectionMade = true; // A selection has been made
    });

    // Animate the icon from the selected tile to the next button
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? startBox =
          _tileKeys[languageCode]!.currentContext?.findRenderObject() as RenderBox?;
      final RenderBox? endBox =
          _appBarActionKey.currentContext?.findRenderObject() as RenderBox?;

      if (startBox != null && endBox != null) {
        final startOffset = startBox.localToGlobal(startBox.size.center(Offset.zero));
        final endOffset = endBox.localToGlobal(endBox.size.center(Offset.zero));

        _animation = Tween<Offset>(
          begin: startOffset,
          end: endOffset,
        ).animate(CurvedAnimation(
          parent: _animationController!,
          curve: Curves.easeInOut,
        ));

        setState(() {
          _isAnimating = true; // Start the animation
        });
        _animationController!.forward(from: 0.0);
      }
    });
  }

  void _onNext() async {
    // This button should only be pressable if a language is selected and not animating.
    if (_selectedLanguageCode != null && !_isAnimating) {
      final locale = Locale(_selectedLanguageCode!);
      Provider.of<AppProvider>(context, listen: false).setLocale(locale);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', _selectedLanguageCode!);

      if (!mounted) return;
      if (widget.isInitialSetup) {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) =>
                  const CurrencySelectionScreen(isInitialSetup: true)),
        );
      } else {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
        automaticallyImplyLeading: !widget.isInitialSetup,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              key: _appBarActionKey,
              icon: Icon(
                Icons.check_circle,
                color: _selectedLanguageCode != null && !_isAnimating
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withAlpha(128),
                size: 30,
              ),
              onPressed: (_selectedLanguageCode != null && !_isAnimating) ? _onNext : null,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please select language to continue',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final code = _languages.keys.elementAt(index);
                      final lang = _languages[code]!;
                      return LanguageTile(
                        key: _tileKeys[code],
                        title: lang['name']!,
                        icon: lang['icon']!,
                        isSelected: _selectedLanguageCode == code,
                        onTap: () => _onLanguageSelected(code),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Show static icon over 'English' before any selection is made
          if (!_selectionMade && _initialIconOffset != null)
            Positioned(
              left: _initialIconOffset!.dx - 15,
              top: _initialIconOffset!.dy - 15,
              child: const Icon(Icons.touch_app, size: 30, color: Colors.green),
            ),
          
          // Show animating/final icon after a selection is made
          if (_selectionMade && _animation != null)
            AnimatedBuilder(
              animation: _animation!,
              builder: (context, child) {
                return Positioned(
                  left: _animation!.value.dx - 15,
                  top: _animation!.value.dy - 15,
                  child: const Icon(Icons.touch_app, size: 30, color: Colors.green),
                );
              },
            ),
        ],
      ),
    );
  }
}
