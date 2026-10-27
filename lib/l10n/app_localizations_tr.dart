// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Cüzdan';

  @override
  String greeting(String name) {
    return 'Merhaba, $name';
  }

  @override
  String get loadFailed =>
      'Veriler yüklenemedi. Uygulamayı kapatıp yeniden aç.';

  @override
  String get tabSummary => 'Özet';

  @override
  String get tabCalendar => 'Takvim';

  @override
  String get settings => 'Ayarlar';

  @override
  String get remaining => 'Kalan';

  @override
  String statusDaysLeft(int days) {
    return 'Maaşa $days gün kaldı';
  }

  @override
  String get statusPaydayTomorrow => 'Yarın maaş günü';

  @override
  String get statusPeriodClosed => 'Dönem kapandı';

  @override
  String get statusOverBudget => 'Bütçe aşıldı';

  @override
  String get statSpent => 'Harcanan';

  @override
  String get statSalary => 'Maaş';

  @override
  String get previousPeriod => 'Önceki dönem';

  @override
  String get nextPeriod => 'Sonraki dönem';

  @override
  String get previousMonth => 'Önceki ay';

  @override
  String get nextMonth => 'Sonraki ay';

  @override
  String get categoriesTitle => 'Kategoriler';

  @override
  String get expensesTitle => 'Harcamalar';

  @override
  String get recentTitle => 'Son harcamalar';

  @override
  String get seeAll => 'Tümünü gör';

  @override
  String get emptyExpensesTitle => 'Bu dönem henüz harcama yok';

  @override
  String get emptyExpensesBody =>
      'İlk harcamanı eklemek için Harcama ekle düğmesine dokun.';

  @override
  String get noExpensesOnDay => 'Bu gün için harcama yok.';

  @override
  String get today => 'Bugün';

  @override
  String get yesterday => 'Dün';

  @override
  String get addExpense => 'Harcama ekle';

  @override
  String get expenseDeleted => 'Harcama silindi';

  @override
  String get undo => 'Geri al';

  @override
  String get newExpense => 'Yeni harcama';

  @override
  String get editExpense => 'Harcamayı düzenle';

  @override
  String get amountRequired => 'Bir tutar gir';

  @override
  String get amountInvalid => 'Geçerli bir tutar gir, örneğin 125 ya da 89,90';

  @override
  String get categoryLabel => 'Kategori';

  @override
  String get categoryRequired => 'Bir kategori seç';

  @override
  String get noteLabel => 'Not (isteğe bağlı)';

  @override
  String get dateLabel => 'Tarih';

  @override
  String get otherDay => 'Başka gün';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get categoryFood => 'Yemek';

  @override
  String get categoryCoffee => 'Kahve';

  @override
  String get categoryGroceries => 'Market';

  @override
  String get categoryShopping => 'Alışveriş';

  @override
  String get categoryBeauty => 'Bakım';

  @override
  String get categoryTransport => 'Ulaşım';

  @override
  String get categoryBills => 'Fatura';

  @override
  String get categoryRent => 'Kira';

  @override
  String get categoryHealth => 'Sağlık';

  @override
  String get categoryEntertainment => 'Eğlence';

  @override
  String get categoryGift => 'Hediye';

  @override
  String get categoryOther => 'Diğer';

  @override
  String get welcomeTitle => 'Cüzdan\'a hoş geldin';

  @override
  String get welcomeBody =>
      'Maaşını ve maaş gününü gir. Harcamalarını ekledikçe maaş gününe kadar ne kadar kaldığını görürsün.';

  @override
  String get nameLabel => 'Adın';

  @override
  String get nameHint => 'İsteğe bağlı';

  @override
  String get salaryLabel => 'Aylık maaşın';

  @override
  String get salaryRequired => 'Maaş tutarını gir';

  @override
  String get paydayLabel => 'Maaş günün';

  @override
  String get paydayHelper =>
      'Dönemler bu güne göre hesaplanır. Ay bu günden kısaysa ayın son günü sayılır.';

  @override
  String paydayValue(int day) {
    return 'Her ayın $day. günü';
  }

  @override
  String get paydayPickerTitle => 'Maaşın ayın kaçında yatıyor?';

  @override
  String get start => 'Başla';

  @override
  String get sectionProfile => 'Profil';

  @override
  String get sectionSalary => 'Maaş';

  @override
  String get sectionAppearance => 'Görünüm';

  @override
  String get sectionData => 'Veriler';

  @override
  String get nameNotSet => 'Belirtilmedi';

  @override
  String get salaryAppliesFromNow =>
      'Bu dönemden itibaren geçerli olur. Geçmiş dönemler değişmez.';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get recurringTitle => 'Tekrarlayan harcamalar';

  @override
  String recurringSummary(int count, String amount) {
    return '$count harcama, ayda toplam $amount';
  }

  @override
  String get recurringSummaryEmpty => 'Kira, fatura ve abonelikler';

  @override
  String get recurringEmptyTitle => 'Henüz tekrarlayan harcama yok';

  @override
  String get recurringEmptyBody =>
      'Harcama eklerken Tekrar bölümünden Her ay\'ı seç. Kira, fatura ve abonelikler her ay kendiliğinden eklenir.';

  @override
  String get recurringMonthlyTotal => 'Aylık toplam';

  @override
  String get recurringBadge => 'Tekrarlayan harcama';

  @override
  String get editRecurring => 'Tekrarlayanı düzenle';

  @override
  String get recurringDayLabel => 'Her ay eklenme günü';

  @override
  String get recurringDayPickerTitle => 'Ayın kaçında eklensin?';

  @override
  String get repeatLabel => 'Tekrar';

  @override
  String get repeatOnce => 'Tek seferlik';

  @override
  String get repeatMonthly => 'Her ay';

  @override
  String repeatMonthlySubtitle(int day) {
    return 'Her ayın $day. günü otomatik eklenir';
  }

  @override
  String get deleteRecurringTitle => 'Tekrarlayan harcama silinsin mi?';

  @override
  String get deleteRecurringBody =>
      'Bundan sonra otomatik eklenmez. Daha önce eklenenler kalır.';

  @override
  String get exportExcel => 'Excel\'e aktar';

  @override
  String get exportExcelSubtitle =>
      'Tüm harcamaları .xlsx dosyası olarak kaydet';

  @override
  String get exportSaved => 'Excel dosyası kaydedildi';

  @override
  String get exportFailed => 'Dosya kaydedilemedi. Tekrar dene.';

  @override
  String get exportEmpty => 'Aktarılacak harcama yok';

  @override
  String get sheetExpenses => 'Harcamalar';

  @override
  String get sheetSummary => 'Dönem özeti';

  @override
  String get columnDate => 'Tarih';

  @override
  String get columnCategory => 'Kategori';

  @override
  String get columnNote => 'Not';

  @override
  String get columnAmount => 'Tutar (₺)';

  @override
  String get columnPeriod => 'Dönem';

  @override
  String get columnSalary => 'Maaş (₺)';

  @override
  String get columnSpent => 'Harcanan (₺)';

  @override
  String get columnRemaining => 'Kalan (₺)';

  @override
  String get exportFileName => 'cuzdan-harcamalar';
}
