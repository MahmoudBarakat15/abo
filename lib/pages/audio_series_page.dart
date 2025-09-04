import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lesson_page.dart'; // إستيراد صفحة الدروس

// صفحة السلاسل الصوتية
class AudioSeriesPage extends StatelessWidget {
  AudioSeriesPage({super.key});

  final List<Map<String, dynamic>> lessons = [
    {
      "title": "شمائل النبى ﷺ وسيرته كأنك تراه",
      "count": 5,
      "id": "shamael_nabawi",
    },
    {"title": "أيها العاصي أقبل", "count": 2, "id": "ayuha_alasi"},
    {
      "title": "(سمعنا وأطعنا (عبودية الاستجابة",
      "count": 2,
      "id": "samina_wa_atana",
    },
    {"title": "داء الأمة", "count": 2, "id": "daa_al_ummah"},
    {"title": "جيل التمكين", "count": 2, "id": "jeel_tamkeen"},
    {"title": "الإحسان وأثره في التمكين", "count": 2, "id": "ihsan_tamkeen"},
    {"title": "أثــر الإســلام في الرجــال", "count": 2, "id": "athar_islam"},
    {"title": "الطريق من هنا", "count": 2, "id": "tareek_min_huna"},
    {"title": "حالة ضعف المسلمين", "count": 2, "id": "hala_daaf"},
    {"title": "تعلم الإيمان قبل القرآن", "count": 2, "id": "talam_iman"},
    {
      "title": "سلسلة فنّ إدارة الحياة الزوجية",
      "count": 3,
      "id": "fan_idarat_zawaj",
    },
    {"title": "الأسباب المعينة علي الصبر", "count": 4, "id": "asbab_sabr"},
    {"title": "حكم الغناء والموسيقى", "count": 2, "id": "hukm_ghina"},
    {"title": "الأخذ بالأسباب", "count": 2, "id": "akhz_asbab"},
    {"title": "الأخوة", "count": 2, "id": "ukhuwah"},
    {"title": "الجزاء من جنس العمل", "count": 2, "id": "jaza_amal"},
    {"title": "الغلو", "count": 2, "id": "ghuluw"},
    {"title": "الإنتكاس", "count": 2, "id": "intikas"},
    {
      "title": "الشرح النفيس لاختصار علوم الحديث",
      "count": 15,
      "id": "sharh_uloom_hadith",
    },
    {"title": "المبتدع والحمل الثقيل", "count": 2, "id": "mubtadi_haml"},
    {"title": "دروس المساجد", "count": 1, "id": "durus_masajid"},
    {"title": "قطوف", "count": 10, "id": "qutuf"},
    {"title": "خطب منبرية", "count": 1, "id": "khutab"},
    {"title": "زاد الغريب", "count": 20, "id": "zad_ghareeb"},
    {"title": "شرح حديث الإفك", "count": 9, "id": "sharh_ifk"},
    {"title": "شرح الباعث الحثيث", "count": 6, "id": "sharh_baaith"},
    {"title": "مدرسة الحياة", "count": 4, "id": "madrasa_hayah"},
    {"title": "السيرة النبوية", "count": 14, "id": "seerah"},
    {"title": "علامات المحبة", "count": 7, "id": "alamat_mahaba"},
    {"title": "آداب طالب العلم", "count": 2, "id": "adab_talib"},
    {"title": "آداب الخلاف", "count": 2, "id": "adab_khilaf"},
    {"title": "اختيار الزوجة الصالحة", "count": 2, "id": "ikhtiyar_zawja"},
    {
      "title": "إتحاف النبلاء بمسائل الولاء والبراء",
      "count": 2,
      "id": "ithaf_nobala",
    },
    {"title": "فى رحاب سورة القصص", "count": 5, "id": "surat_qasas"},
    {"title": "نداء الغرباء", "count": 2, "id": "nida_ghoraba"},
    {
      "title": "شمائل النبي صلى الله عليه وسلم",
      "count": 6,
      "id": "shamael_nabi",
    },
    {"title": "منزلة التوبة", "count": 2, "id": "manzila_tawba"},
    {"title": "مفسدات القلوب", "count": 2, "id": "mufsidhat_qulub"},
    {"title": "ما شاء الله كان", "count": 2, "id": "ma_shaa_allah"},
    {"title": "لا عدوى", "count": 2, "id": "la_adwa"},
    {
      "title": "كلمة التوحيد قبل توحيد الكلمة",
      "count": 2,
      "id": "kalima_tawheed",
    },
    {"title": "كلٌ يغدو", "count": 2, "id": "kul_yaghdu"},
    {"title": "كتابات ضد الاسلام", "count": 2, "id": "kitabat_islam"},
    {"title": "قل هو نبأ عظيم", "count": 2, "id": "naba_azeem"},
    {"title": "علامات على طريق التمكين", "count": 4, "id": "alamat_tamkeen"},
    {"title": "صناعة الرجال", "count": 2, "id": "sinaat_rijal"},
    {"title": "صــلاح الآبــاء", "count": 2, "id": "salah_abaa"},
    {"title": "صدق الانتماء إلى الدعوة", "count": 2, "id": "sidq_intimaa"},
    {"title": "شروط العمل الصالح", "count": 4, "id": "shuroot_amal"},
    {"title": "سلِّ صيامك", "count": 2, "id": "sal_siyamak"},
    {"title": "لماذا لا نُحب الله ؟", "count": 4, "id": "limaza_nuhib"},
    {"title": "دينك أغلى من بدنك", "count": 2, "id": "deenuk_aghla"},
    {"title": "وأوحينا إلى أم موسى", "count": 3, "id": "um_musa"},
    {
      "title": "دروس وعبر من حديث مقتل عمر رضي الله عنه",
      "count": 6,
      "id": "maqtal_umar",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B4332), Color(0xFF2D5A47), Color(0xFF40916C)],
          ),
        ),
        child: Column(
          children: [
            // App Bar مخصص
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.library_music_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "السلاسل الصوتية",
                          style: GoogleFonts.cairo(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "مجموعة مختارة من الدروس والمحاضرات",
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // قائمة السلاسل
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: lessons.length,
                separatorBuilder: (_, __) => SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final lesson = lessons[index];
                  final int count = lesson["count"] as int;

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LessonsPage(
                                seriesTitle: lesson["title"],
                                seriesId: lesson["id"],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              // أيقونة السلسلة
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF95D5B2),
                                      Color(0xFF52B788),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF52B788).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.headphones_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),

                              SizedBox(width: 15),

                              // محتوى السلسلة
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      lesson["title"],
                                      style: GoogleFonts.cairo(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(
                                              0xFF95D5B2,
                                            ).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Color(
                                                0xFF95D5B2,
                                              ).withOpacity(0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            textDirection: TextDirection.rtl,
                                            children: [
                                              Text(
                                                "($count)",
                                                style: GoogleFonts.cairo(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF95D5B2),
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                "درس",
                                                style: GoogleFonts.cairo(
                                                  fontSize: 12,
                                                  color: Color(0xFF95D5B2),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: 10),

                              // سهم الانتقال
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
