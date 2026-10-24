import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/services/locale_service.dart';
import '../../../app/utils/app_colors.dart';


class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({Key? key}) : super(key: key);

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  String selectedLanguage = '';

  @override
  void initState() {
    super.initState();
    selectedLanguage = LocaleService.isFrench ? 'fr' : 'en';
  }

  Future<void> _changeLanguage(String code) async {
    setState(() {
      selectedLanguage = code;
    });
    await LocaleService.setLocale(Locale(code));
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> languages = {
      'fr': AppLocalization.tr.frenchLanguage,
      'en': AppLocalization.tr.englishLanguage,
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: SettingsColors.primaryText,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalization.tr.changeLanguageTitle,
          style: const TextStyle(
            color: SettingsColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding:  EdgeInsets.all(20.sp),
        child: Column(
          children: languages.entries
              .map((entry) => _buildLanguageOption(entry.key, entry.value))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String language) {
    final isSelected = selectedLanguage == code;

    return InkWell(
      onTap: () {
        _changeLanguage(code);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child:Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            language,
            style: TextStyle(
              fontSize: 16,
              color: isSelected
                  ? SettingsColors.primaryText
                  : SettingsColors.secondaryText,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? SettingsColors.radioSelected
                    : SettingsColors.radioUnselected,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: SettingsColors.radioSelected,
                  shape: BoxShape.circle,
                ),
              ),
            )
                : null,
          ),
        ],
      ),
    )
    ,
      ),
    );
  }
}
