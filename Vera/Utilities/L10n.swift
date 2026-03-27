import Foundation

enum L10n {
    enum Prayer {
        static let imsak = NSLocalizedString("prayer_imsak", comment: "")
        static let sunrise = NSLocalizedString("prayer_sunrise", comment: "")
        static let dhuhr = NSLocalizedString("prayer_dhuhr", comment: "")
        static let asr = NSLocalizedString("prayer_asr", comment: "")
        static let maghrib = NSLocalizedString("prayer_maghrib", comment: "")
        static let isha = NSLocalizedString("prayer_isha", comment: "")
    }
    
    enum Home {
        static let title = NSLocalizedString("home_vakitler", comment: "")
        static let monthlyImsakiye = NSLocalizedString("home_vakitler_aylik", comment: "")
        static let monthlyImsakiyeSub = NSLocalizedString("home_vakitler_aylik_alt", comment: "")
        static let sponsored = NSLocalizedString("home_sponsorlu", comment: "")
        static let loading = NSLocalizedString("home_yukleniyor", comment: "")
        static let retry = NSLocalizedString("home_hata_tekrar_dene", comment: "")
        static let selectLocation = NSLocalizedString("home_konum_sec", comment: "")
        static let waitingLocation = NSLocalizedString("home_konum_bekle", comment: "")
    }
    
    enum Hero {
        static let currentPrayer = NSLocalizedString("hero_su_anki_vakit", comment: "")
        
        static func timeRemaining(to prayer: String) -> String {
            let format = NSLocalizedString("hero_vakit_kalan", comment: "")
            return String(format: format, prayer)
        }
        
        static func prayerEntered(prayer: String) -> String {
            let format = NSLocalizedString("hero_vakit_girdi", comment: "")
            return String(format: format, prayer)
        }
    }
    
    enum Common {
        static let ok = NSLocalizedString("common_tamam", comment: "")
        static let done = NSLocalizedString("common_tamam", comment: "")
        static let close = NSLocalizedString("common_kapat", comment: "")
        static let cancel = NSLocalizedString("common_iptal", comment: "")
        static let reset = NSLocalizedString("common_sifirla", comment: "")
        static let save = NSLocalizedString("common_kaydet", comment: "")
        static let next = NSLocalizedString("common_ileri", comment: "")
        static let back = NSLocalizedString("common_geri", comment: "")
        static let finish = NSLocalizedString("common_bitti", comment: "")
    }
    
    enum Settings {
        static let title = NSLocalizedString("settings_title", comment: "")
        static let subtitle = NSLocalizedString("settings_subtitle", comment: "")
        
        static let general = NSLocalizedString("settings_genel", comment: "")
        static let notifications = NSLocalizedString("settings_bildirimler", comment: "")
        static let widget = NSLocalizedString("settings_widget", comment: "")
        static let autoLocation = NSLocalizedString("settings_oto_konum", comment: "")
        
        static let appearance = NSLocalizedString("settings_gorunum_dil", comment: "")
        static let theme = NSLocalizedString("settings_tema", comment: "")
        static let themeSystem = NSLocalizedString("settings_tema_sistem", comment: "")
        static let themeLight = NSLocalizedString("settings_tema_acik", comment: "")
        static let themeDark = NSLocalizedString("settings_tema_koyu", comment: "")
        static let language = NSLocalizedString("settings_dil", comment: "")
        static let languageName = NSLocalizedString("settings_dil_tr", comment: "")
        
        static let quran = NSLocalizedString("settings_kuran", comment: "")
        static let quranAuthor = NSLocalizedString("settings_meal_yazar", comment: "")
        
        static let support = NSLocalizedString("settings_destek", comment: "")
        static let contact = NSLocalizedString("settings_ulasin", comment: "")
        static let faq = NSLocalizedString("settings_yardim", comment: "")
        static let about = NSLocalizedString("settings_hakkimizda", comment: "")
    }
    
    enum Location {
        static let selected = NSLocalizedString("location_secilen", comment: "")
        static let auto = NSLocalizedString("location_otomatik_bul", comment: "")
        static let manual = NSLocalizedString("location_manuel_sec", comment: "")
        static let change = NSLocalizedString("location_farkli_sec", comment: "")
        static let searching = NSLocalizedString("location_araniyor", comment: "")
    }
    
    enum Onboarding {
        static let start = NSLocalizedString("onboarding_basla", comment: "")
        static let next = NSLocalizedString("onboarding_devam", comment: "")
        static let awesomeNext = NSLocalizedString("onboarding_harika", comment: "")
        static let finish = NSLocalizedString("onboarding_basla", comment: "")
        static let skip = NSLocalizedString("onboarding_gec", comment: "")
        static let grantPermission = NSLocalizedString("onboarding_izin_ver", comment: "")
        static let anladim = NSLocalizedString("onboarding_anladim", comment: "")
        
        enum Step1 {
            static let title = NSLocalizedString("onboarding_s1_title", comment: "")
            static let desc = NSLocalizedString("onboarding_s1_desc", comment: "")
        }
        
        enum Step2 {
            static let title = NSLocalizedString("onboarding_s2_title", comment: "")
            static let desc = NSLocalizedString("onboarding_s2_desc", comment: "")
            static let loading = NSLocalizedString("onboarding_s2_loading", comment: "")
        }
        
        enum Step3 {
            static let title = NSLocalizedString("onboarding_s3_title", comment: "")
            static let desc = NSLocalizedString("onboarding_s3_desc", comment: "")
        }
        
        enum Step4 {
            static let title = NSLocalizedString("onboarding_s4_title", comment: "")
        }
        
        enum Step5 {
            static let title = NSLocalizedString("onboarding_s5_title", comment: "")
            static let desc = NSLocalizedString("onboarding_s5_desc", comment: "")
            static let toggle = NSLocalizedString("onboarding_s5_toggle", comment: "")
            static let durationTitle = NSLocalizedString("onboarding_s5_duration", comment: "")
            static func minutes(_ val: Int) -> String {
                let format = NSLocalizedString("onboarding_s5_min", comment: "")
                return String(format: format, val)
            }
        }
        
        enum Step6 {
            static let title = NSLocalizedString("onboarding_s6_title", comment: "")
            static let warning1 = NSLocalizedString("onboarding_s6_warning1", comment: "")
            static let warning2 = NSLocalizedString("onboarding_s6_warning2", comment: "")
        }
        
        enum Step7 {
            static let title = NSLocalizedString("onboarding_s7_title", comment: "")
            static let desc = NSLocalizedString("onboarding_s7_desc", comment: "")
        }
    }
    
    enum Zakat {
        static let title = NSLocalizedString("zakat_title", comment: "")
        static let pricesTitle = NSLocalizedString("zakat_birikim_fiyatlari", comment: "")
        static let goldPrice = NSLocalizedString("zakat_altin_gr", comment: "")
        static let silverPrice = NSLocalizedString("zakat_gumus_gr", comment: "")
        
        static let cashBank = NSLocalizedString("zakat_nakit_banka", comment: "")
        static let cash = NSLocalizedString("zakat_nakit_para", comment: "")
        static let bank = NSLocalizedString("zakat_banka_hesaplari", comment: "")
        static let foreign = NSLocalizedString("zakat_doviz", comment: "")
        
        static let preciousMetals = NSLocalizedString("zakat_ziynet", comment: "")
        static let gold24k = NSLocalizedString("zakat_altin_24k", comment: "")
        static let gold22k = NSLocalizedString("zakat_altin_22k", comment: "")
        static let silverGr = NSLocalizedString("zakat_gumus_gr_input", comment: "")
        
        static let trade = NSLocalizedString("zakat_ticaret", comment: "")
        static let commercial = NSLocalizedString("zakat_ticari", comment: "")
        static let receivables = NSLocalizedString("zakat_alacaklar", comment: "")
        
        static let debtsTitle = NSLocalizedString("zakat_borclar", comment: "")
        static let debts = NSLocalizedString("zakat_borclar_odenecek", comment: "")
        
        static let agriculture = NSLocalizedString("zakat_tarim", comment: "")
        static let yield = NSLocalizedString("zakat_mahsul", comment: "")
        static let irrigationCostly = NSLocalizedString("zakat_sulama_masrafli", comment: "")
        static let rate5 = NSLocalizedString("zakat_oran_5", comment: "")
        static let rate10 = NSLocalizedString("zakat_oran_10", comment: "")
        
        static let netAssets = NSLocalizedString("zakat_net_varlik", comment: "")
        static let nisabThreshold = NSLocalizedString("zakat_nisap_baraji", comment: "")
        static let totalZakat = NSLocalizedString("zakat_toplam_miktar", comment: "")
        static let notRequired = NSLocalizedString("zakat_hesap_gerekmiyor", comment: "")
        
        static func detail(general: Double, agriculture: Double) -> String {
            let format = NSLocalizedString("zakat_genel_osur_detay", comment: "")
            return String(format: format, general, agriculture)
        }
        
        enum Info {
            static let title = NSLocalizedString("zakat_info_title", comment: "")
            static let howTo = NSLocalizedString("zakat_info_nasil_hesaplanir", comment: "")
            static let howToDesc = NSLocalizedString("zakat_info_nasil_hesaplanir_desc", comment: "")
            
            static let ornament = NSLocalizedString("zakat_info_zinet", comment: "")
            static let ornamentDesc = NSLocalizedString("zakat_info_zinet_desc", comment: "")
            
            static let agriculture = NSLocalizedString("zakat_info_zirai", comment: "")
            static let agricultureDesc = NSLocalizedString("zakat_info_zirai_desc", comment: "")
            
            static let nisab = NSLocalizedString("zakat_info_nisap", comment: "")
            static let nisabDesc = NSLocalizedString("zakat_info_nisap_desc", comment: "")
            
            static let salary = NSLocalizedString("zakat_info_maas", comment: "")
            static let salaryDesc = NSLocalizedString("zakat_info_maas_desc", comment: "")
        }
    }
    
    enum Tab {
        static let home = NSLocalizedString("tab_ana_sayfa", comment: "")
        static let quran = NSLocalizedString("tab_kuran", comment: "")
        static let qibla = NSLocalizedString("tab_kible", comment: "")
        static let religiousDays = NSLocalizedString("tab_dini_gunler", comment: "")
        static let menu = NSLocalizedString("tab_menu", comment: "")
    }
    
    enum NearbyMosques {
        static let title = NSLocalizedString("mosques_title", comment: "")
        static let searching = NSLocalizedString("mosques_searching", comment: "")
        static let notFound = NSLocalizedString("mosques_not_found", comment: "")
        static let directions = NSLocalizedString("mosques_get_directions", comment: "")
        static let unknown = NSLocalizedString("mosques_unknown", comment: "")
        static let searchQuery = NSLocalizedString("mosques_search_query", comment: "")
    }

    enum Quran {
        static let title = NSLocalizedString("quran_title", comment: "")
        static let surahs = NSLocalizedString("quran_surahs", comment: "")
        static let loading = NSLocalizedString("quran_loading", comment: "")
        static let verse = NSLocalizedString("quran_verse", comment: "")
        static let page = NSLocalizedString("quran_page", comment: "")
    }

    enum Dhikr {
        static let title = NSLocalizedString("dhikr_title", comment: "")
        static let resetTitle = NSLocalizedString("dhikr_reset_title", comment: "")
        static let resetMessage = NSLocalizedString("dhikr_reset_message", comment: "")
        static let target = NSLocalizedString("dhikr_target", comment: "")
        static let noTarget = NSLocalizedString("dhikr_no_target", comment: "")
        static let setTarget = NSLocalizedString("dhikr_set_target", comment: "")
        static let newTarget = NSLocalizedString("dhikr_new_target", comment: "")
        static let targetDesc = NSLocalizedString("dhikr_target_desc", comment: "")
        static let selectTesbihat = NSLocalizedString("dhikr_select_tesbihat", comment: "")
        
        static let subhanallah = NSLocalizedString("dhikr_subhanallah", comment: "")
        static let elhamdulillah = NSLocalizedString("dhikr_elhamdulillah", comment: "")
        static let allahuekber = NSLocalizedString("dhikr_allahuekber", comment: "")
        static let tevhidi = NSLocalizedString("dhikr_tevhidi", comment: "")
        static let salavat = NSLocalizedString("dhikr_salavat", comment: "")
        static let estagfirullah = NSLocalizedString("dhikr_estagfirullah", comment: "")
        static let free = NSLocalizedString("dhikr_free", comment: "")
    }
}
