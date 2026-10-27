import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('tr')];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Cüzdan'**
  String get appTitle;

  /// No description provided for @greeting.
  ///
  /// In tr, this message translates to:
  /// **'Merhaba, {name}'**
  String greeting(String name);

  /// No description provided for @loadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Veriler yüklenemedi. Uygulamayı kapatıp yeniden aç.'**
  String get loadFailed;

  /// No description provided for @tabSummary.
  ///
  /// In tr, this message translates to:
  /// **'Özet'**
  String get tabSummary;

  /// No description provided for @tabCalendar.
  ///
  /// In tr, this message translates to:
  /// **'Takvim'**
  String get tabCalendar;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @remaining.
  ///
  /// In tr, this message translates to:
  /// **'Kalan'**
  String get remaining;

  /// No description provided for @statusDaysLeft.
  ///
  /// In tr, this message translates to:
  /// **'Maaşa {days} gün kaldı'**
  String statusDaysLeft(int days);

  /// No description provided for @statusPaydayTomorrow.
  ///
  /// In tr, this message translates to:
  /// **'Yarın maaş günü'**
  String get statusPaydayTomorrow;

  /// No description provided for @statusPeriodClosed.
  ///
  /// In tr, this message translates to:
  /// **'Dönem kapandı'**
  String get statusPeriodClosed;

  /// No description provided for @statusOverBudget.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe aşıldı'**
  String get statusOverBudget;

  /// No description provided for @statSpent.
  ///
  /// In tr, this message translates to:
  /// **'Harcanan'**
  String get statSpent;

  /// No description provided for @statDailyLimit.
  ///
  /// In tr, this message translates to:
  /// **'Günlük limit'**
  String get statDailyLimit;

  /// No description provided for @statSalary.
  ///
  /// In tr, this message translates to:
  /// **'Maaş'**
  String get statSalary;

  /// No description provided for @previousPeriod.
  ///
  /// In tr, this message translates to:
  /// **'Önceki dönem'**
  String get previousPeriod;

  /// No description provided for @nextPeriod.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki dönem'**
  String get nextPeriod;

  /// No description provided for @previousMonth.
  ///
  /// In tr, this message translates to:
  /// **'Önceki ay'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki ay'**
  String get nextMonth;

  /// No description provided for @categoriesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get categoriesTitle;

  /// No description provided for @expensesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcamalar'**
  String get expensesTitle;

  /// No description provided for @recentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Son harcamalar'**
  String get recentTitle;

  /// No description provided for @seeAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü gör'**
  String get seeAll;

  /// No description provided for @emptyExpensesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu dönem henüz harcama yok'**
  String get emptyExpensesTitle;

  /// No description provided for @emptyExpensesBody.
  ///
  /// In tr, this message translates to:
  /// **'İlk harcamanı eklemek için Harcama ekle düğmesine dokun.'**
  String get emptyExpensesBody;

  /// No description provided for @noExpensesOnDay.
  ///
  /// In tr, this message translates to:
  /// **'Bu gün için harcama yok.'**
  String get noExpensesOnDay;

  /// No description provided for @today.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In tr, this message translates to:
  /// **'Dün'**
  String get yesterday;

  /// No description provided for @addExpense.
  ///
  /// In tr, this message translates to:
  /// **'Harcama ekle'**
  String get addExpense;

  /// No description provided for @expenseDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Harcama silindi'**
  String get expenseDeleted;

  /// No description provided for @undo.
  ///
  /// In tr, this message translates to:
  /// **'Geri al'**
  String get undo;

  /// No description provided for @newExpense.
  ///
  /// In tr, this message translates to:
  /// **'Yeni harcama'**
  String get newExpense;

  /// No description provided for @editExpense.
  ///
  /// In tr, this message translates to:
  /// **'Harcamayı düzenle'**
  String get editExpense;

  /// No description provided for @amountRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bir tutar gir'**
  String get amountRequired;

  /// No description provided for @amountInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir tutar gir, örneğin 125 ya da 89,90'**
  String get amountInvalid;

  /// No description provided for @categoryLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get categoryLabel;

  /// No description provided for @categoryRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bir kategori seç'**
  String get categoryRequired;

  /// No description provided for @noteLabel.
  ///
  /// In tr, this message translates to:
  /// **'Not (isteğe bağlı)'**
  String get noteLabel;

  /// No description provided for @dateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get dateLabel;

  /// No description provided for @otherDay.
  ///
  /// In tr, this message translates to:
  /// **'Başka gün'**
  String get otherDay;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @categoryFood.
  ///
  /// In tr, this message translates to:
  /// **'Yemek'**
  String get categoryFood;

  /// No description provided for @categoryCoffee.
  ///
  /// In tr, this message translates to:
  /// **'Kahve'**
  String get categoryCoffee;

  /// No description provided for @categoryGroceries.
  ///
  /// In tr, this message translates to:
  /// **'Market'**
  String get categoryGroceries;

  /// No description provided for @categoryShopping.
  ///
  /// In tr, this message translates to:
  /// **'Alışveriş'**
  String get categoryShopping;

  /// No description provided for @categoryBeauty.
  ///
  /// In tr, this message translates to:
  /// **'Bakım'**
  String get categoryBeauty;

  /// No description provided for @categoryTransport.
  ///
  /// In tr, this message translates to:
  /// **'Ulaşım'**
  String get categoryTransport;

  /// No description provided for @categoryBills.
  ///
  /// In tr, this message translates to:
  /// **'Fatura'**
  String get categoryBills;

  /// No description provided for @categoryRent.
  ///
  /// In tr, this message translates to:
  /// **'Kira'**
  String get categoryRent;

  /// No description provided for @categoryHealth.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık'**
  String get categoryHealth;

  /// No description provided for @categoryEntertainment.
  ///
  /// In tr, this message translates to:
  /// **'Eğlence'**
  String get categoryEntertainment;

  /// No description provided for @categoryGift.
  ///
  /// In tr, this message translates to:
  /// **'Hediye'**
  String get categoryGift;

  /// No description provided for @categoryOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get categoryOther;

  /// No description provided for @welcomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Cüzdan\'a hoş geldin'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In tr, this message translates to:
  /// **'Maaşını ve maaş gününü gir. Harcamalarını ekledikçe maaş gününe kadar ne kadar kaldığını görürsün.'**
  String get welcomeBody;

  /// No description provided for @nameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Adın'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In tr, this message translates to:
  /// **'İsteğe bağlı'**
  String get nameHint;

  /// No description provided for @salaryLabel.
  ///
  /// In tr, this message translates to:
  /// **'Aylık maaşın'**
  String get salaryLabel;

  /// No description provided for @salaryRequired.
  ///
  /// In tr, this message translates to:
  /// **'Maaş tutarını gir'**
  String get salaryRequired;

  /// No description provided for @paydayLabel.
  ///
  /// In tr, this message translates to:
  /// **'Maaş günün'**
  String get paydayLabel;

  /// No description provided for @paydayHelper.
  ///
  /// In tr, this message translates to:
  /// **'Dönemler bu güne göre hesaplanır. Ay bu günden kısaysa ayın son günü sayılır.'**
  String get paydayHelper;

  /// No description provided for @paydayValue.
  ///
  /// In tr, this message translates to:
  /// **'Her ayın {day}. günü'**
  String paydayValue(int day);

  /// No description provided for @paydayPickerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Maaşın ayın kaçında yatıyor?'**
  String get paydayPickerTitle;

  /// No description provided for @start.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get start;

  /// No description provided for @sectionProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get sectionProfile;

  /// No description provided for @sectionSalary.
  ///
  /// In tr, this message translates to:
  /// **'Maaş'**
  String get sectionSalary;

  /// No description provided for @sectionAppearance.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get sectionAppearance;

  /// No description provided for @sectionData.
  ///
  /// In tr, this message translates to:
  /// **'Veriler'**
  String get sectionData;

  /// No description provided for @nameNotSet.
  ///
  /// In tr, this message translates to:
  /// **'Belirtilmedi'**
  String get nameNotSet;

  /// No description provided for @salaryAppliesFromNow.
  ///
  /// In tr, this message translates to:
  /// **'Bu dönemden itibaren geçerli olur. Geçmiş dönemler değişmez.'**
  String get salaryAppliesFromNow;

  /// No description provided for @themeSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu'**
  String get themeDark;

  /// No description provided for @recurringTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tekrarlayan harcamalar'**
  String get recurringTitle;

  /// No description provided for @recurringSummary.
  ///
  /// In tr, this message translates to:
  /// **'{count} harcama, ayda toplam {amount}'**
  String recurringSummary(int count, String amount);

  /// No description provided for @recurringSummaryEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Kira, fatura ve abonelikler'**
  String get recurringSummaryEmpty;

  /// No description provided for @recurringEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz tekrarlayan harcama yok'**
  String get recurringEmptyTitle;

  /// No description provided for @recurringEmptyBody.
  ///
  /// In tr, this message translates to:
  /// **'Kira, fatura ve abonelikleri bir kez ekle, her ay kendiliğinden eklensin.'**
  String get recurringEmptyBody;

  /// No description provided for @recurringMonthlyTotal.
  ///
  /// In tr, this message translates to:
  /// **'Aylık toplam'**
  String get recurringMonthlyTotal;

  /// No description provided for @recurringBadge.
  ///
  /// In tr, this message translates to:
  /// **'Tekrarlayan harcama'**
  String get recurringBadge;

  /// No description provided for @addRecurring.
  ///
  /// In tr, this message translates to:
  /// **'Tekrarlayan ekle'**
  String get addRecurring;

  /// No description provided for @newRecurring.
  ///
  /// In tr, this message translates to:
  /// **'Yeni tekrarlayan harcama'**
  String get newRecurring;

  /// No description provided for @editRecurring.
  ///
  /// In tr, this message translates to:
  /// **'Tekrarlayanı düzenle'**
  String get editRecurring;

  /// No description provided for @recurringDayLabel.
  ///
  /// In tr, this message translates to:
  /// **'Her ay eklenme günü'**
  String get recurringDayLabel;

  /// No description provided for @recurringDayPickerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayın kaçında eklensin?'**
  String get recurringDayPickerTitle;

  /// No description provided for @repeatMonthly.
  ///
  /// In tr, this message translates to:
  /// **'Her ay tekrarla'**
  String get repeatMonthly;

  /// No description provided for @repeatMonthlySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Her ayın {day}. günü otomatik eklenir'**
  String repeatMonthlySubtitle(int day);

  /// No description provided for @deleteRecurringTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tekrarlayan harcama silinsin mi?'**
  String get deleteRecurringTitle;

  /// No description provided for @deleteRecurringBody.
  ///
  /// In tr, this message translates to:
  /// **'Bundan sonra otomatik eklenmez. Daha önce eklenenler kalır.'**
  String get deleteRecurringBody;

  /// No description provided for @exportExcel.
  ///
  /// In tr, this message translates to:
  /// **'Excel\'e aktar'**
  String get exportExcel;

  /// No description provided for @exportExcelSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm harcamaları .xlsx dosyası olarak kaydet'**
  String get exportExcelSubtitle;

  /// No description provided for @exportSaved.
  ///
  /// In tr, this message translates to:
  /// **'Excel dosyası kaydedildi'**
  String get exportSaved;

  /// No description provided for @exportFailed.
  ///
  /// In tr, this message translates to:
  /// **'Dosya kaydedilemedi. Tekrar dene.'**
  String get exportFailed;

  /// No description provided for @exportEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Aktarılacak harcama yok'**
  String get exportEmpty;

  /// No description provided for @sheetExpenses.
  ///
  /// In tr, this message translates to:
  /// **'Harcamalar'**
  String get sheetExpenses;

  /// No description provided for @sheetSummary.
  ///
  /// In tr, this message translates to:
  /// **'Dönem özeti'**
  String get sheetSummary;

  /// No description provided for @columnDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get columnDate;

  /// No description provided for @columnCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get columnCategory;

  /// No description provided for @columnNote.
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get columnNote;

  /// No description provided for @columnAmount.
  ///
  /// In tr, this message translates to:
  /// **'Tutar (₺)'**
  String get columnAmount;

  /// No description provided for @columnPeriod.
  ///
  /// In tr, this message translates to:
  /// **'Dönem'**
  String get columnPeriod;

  /// No description provided for @columnSalary.
  ///
  /// In tr, this message translates to:
  /// **'Maaş (₺)'**
  String get columnSalary;

  /// No description provided for @columnSpent.
  ///
  /// In tr, this message translates to:
  /// **'Harcanan (₺)'**
  String get columnSpent;

  /// No description provided for @columnRemaining.
  ///
  /// In tr, this message translates to:
  /// **'Kalan (₺)'**
  String get columnRemaining;

  /// No description provided for @exportFileName.
  ///
  /// In tr, this message translates to:
  /// **'cuzdan-harcamalar'**
  String get exportFileName;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
