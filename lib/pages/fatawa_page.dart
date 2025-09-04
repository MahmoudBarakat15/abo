import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fatwa_detail_page.dart'; // استيراد صفحة تفاصيل الفتوى

// صفحة الفتاوى الرئيسية
class FatawaPage extends StatelessWidget {
  FatawaPage({super.key});

  final List<Map<String, dynamic>> fatawa = [
    {
      "title": "حكم صيام يوم الجمعة منفرداً",
      "id": "siam_jumua",
      "question": "ما حكم صيام يوم الجمعة منفرداً؟",
      "answer":
          "يُكره صيام يوم الجمعة منفرداً، وذلك لما ثبت في الصحيحين من حديث أبي هريرة رضي الله عنه أن النبي صلى الله عليه وسلم قال: \"لا تصوموا يوم الجمعة إلا أن تصوموا يوماً قبله أو يوماً بعده\". والحكمة من ذلك أن يوم الجمعة يوم عيد للمسلمين، فلا يُستحب إفراده بالصيام.",
    },
    {
      "title": "الوضوء من لحم الجمل",
      "id": "wudu_jamal",
      "question": "هل يجب الوضوء من أكل لحم الجمل؟",
      "answer":
          "نعم، يجب الوضوء من أكل لحم الإبل، وذلك لما ثبت في صحيح مسلم من حديث جابر بن سمرة رضي الله عنه أن رجلاً سأل النبي صلى الله عليه وسلم: \"أتوضأ من لحوم الإبل؟\" قال: \"نعم\". وهذا الحكم خاص بلحم الإبل دون غيره من اللحوم.",
    },
    {
      "title": "حكم التصوير الفوتوغرافي",
      "id": "tasweer_photo",
      "question": "ما حكم التصوير الفوتوغرافي للأشخاص؟",
      "answer":
          "اختلف العلماء المعاصرون في حكم التصوير الفوتوغرافي، والراجح أنه جائز للحاجة والمصلحة، كالهوية الشخصية والجواز ونحوها، وذلك لأن التصوير الفوتوغرافي مجرد حبس للظل وليس خلقاً مضاهياً لخلق الله، بخلاف النحت والرسم باليد.",
    },
    {
      "title": "صلاة المرأة في البيت أفضل",
      "id": "salat_marae_bayt",
      "question": "هل صلاة المرأة في البيت أفضل أم في المسجد؟",
      "answer":
          "صلاة المرأة في بيتها أفضل من صلاتها في المسجد، لقول النبي صلى الله عليه وسلم: \"وبيوتهن خير لهن\"، ولكن إذا خرجت للمسجد بضوابطه الشرعية فلا حرج عليها، بل لها أجر الصلاة في المسجد مع الجماعة.",
    },
    {
      "title": "حكم الاستماع للموسيقى",
      "id": "istimaa_musiqa",
      "question": "ما حكم الاستماع للموسيقى والأغاني؟",
      "answer":
          "الموسيقى والأغاني محرمة في الإسلام، لقول النبي صلى الله عليه وسلم: \"ليكونن من أمتي أقوام يستحلون الحر والحرير والخمر والمعازف\"، والمعازف هي آلات الموسيقى. أما الدف فيجوز في الأعياد والأفراح للنساء.",
    },
    {
      "title": "زكاة الذهب والفضة",
      "id": "zakat_zahab",
      "question": "كيف تُحسب زكاة الذهب والفضة؟",
      "answer":
          "زكاة الذهب والفضة تجب إذا بلغت النصاب وحال عليها الحول. نصاب الذهب 85 جراماً، ونصاب الفضة 595 جراماً. والزكاة فيهما ربع العشر (2.5%). ويُزكى ذهب المرأة إذا بلغ النصاب حتى لو كان للزينة على الراجح من أقوال أهل العلم.",
    },
    {
      "title": "حكم صلاة الجمعة للمسافر",
      "id": "jumua_musafir",
      "question": "هل تجب صلاة الجمعة على المسافر؟",
      "answer":
          "لا تجب صلاة الجمعة على المسافر، بل يصلي ظهراً أربع ركعات قصراً إن كان في سفر قصر. لكن إن حضرها مع الناس أجزأته وحصل على فضل الجمعة. والمسافر له رخص كثيرة منها القصر والفطر في رمضان وترك الجمعة.",
    },
    {
      "title": "آداب دخول المسجد",
      "id": "adab_masjid",
      "question": "ما هي آداب دخول المسجد؟",
      "answer":
          "من آداب دخول المسجد: الوضوء، والدخول بالقدم اليمنى، وقول دعاء الدخول، وصلاة تحية المسجد، وعدم رفع الصوت، واجتناب الروائح الكريهة، والخروج بالقدم اليسرى مع دعاء الخروج. كما يُستحب التبكير للصلاة والجلوس في الصف الأول.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF6A4C93), // بنفسجي داكن
              Color(0xFF8E6CB8), // بنفسجي متوسط
              Color(0xFFA68CC7), // بنفسجي فاتح
              Color(0xFFB8A9D1), // لافندر
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Column(
          children: [
            // App Bar مخصص
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 15,
                left: 20,
                right: 20,
                bottom: 25,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "الفتاوى الشرعية",
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "أسئلة وأجوبة في أمور الدين",
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // قائمة الفتاوى
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: fatawa.length,
                separatorBuilder: (_, __) => SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final fatwa = fatawa[index];

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.20),
                          Colors.white.withOpacity(0.08),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                          spreadRadius: -5,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 5,
                          offset: Offset(0, -2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      FatwaDetailPage(
                                        title: fatwa["title"],
                                        question: fatwa["question"],
                                        answer: fatwa["answer"],
                                      ),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOutCubic;

                                    var tween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));

                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                              transitionDuration: Duration(milliseconds: 400),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              // أيقونة الفتوى
                              Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFFB3D9),
                                      Color(0xFFFF8CC8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFFF8CC8).withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.quiz_outlined,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),

                              SizedBox(width: 18),

                              // محتوى الفتوى
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      fatwa["title"],
                                      style: GoogleFonts.cairo(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                    SizedBox(height: 12),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFFB3D9).withOpacity(0.25),
                                            Color(0xFFFF8CC8).withOpacity(0.15),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: Color(
                                            0xFFFFB3D9,
                                          ).withOpacity(0.4),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        textDirection: TextDirection.rtl,
                                        children: [
                                          Icon(
                                            Icons.help_outline_rounded,
                                            size: 16,
                                            color: Color(0xFFFFB3D9),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            "اضغط للقراءة",
                                            style: GoogleFonts.cairo(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFFFB3D9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: 12),

                              // سهم الانتقال
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.2),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Colors.white.withOpacity(0.8),
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
