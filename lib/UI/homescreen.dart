import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:scratcher/scratcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/model.dart';
import '../widgets/drawer.dart';
import '../widgets/header.dart';
import 'azkar/azkarscreen.dart';
import 'diary/diaryscreen.dart';
import 'doaa/doaascree.dart';
import 'goals/goalsscreen.dart';
import 'selfscreen.dart';
import 'tasks/taskscreen.dart';




class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.7);
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  int _currentPage = 0;
  bool _isDialogShownInSession = false;

  late int _currentQuoteIndex = 0;
  late int _currentChallengeIndex = 0;
  late final int _currentFlitterIndex = 0;
  late Timer _timer;
  static const bool isTesting = true; 
  Model model = Model();

  @override
  void initState() {
    super.initState();
    _showDialogs();

    _loadIndices();
    _checkLastUpdateTime();

    _startTimers();

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var dashboard in model.dashboards) {
        precacheImage(AssetImage(dashboard.image), context);
      }
    });
  }



  _showDialogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('is_first_time')??true;

    if (isFirstTime == true) {
      _showFirstTimeDialog();
      prefs.setBool('is_first_time', false);
    }

    if (!_isDialogShownInSession) {
      _isDialogShownInSession = true;
    }
  }

  _showFirstTimeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Welcome'),
          content: const Text('اهلا بيكي يا اوختشي في تطبيق سام  في الصفحة دي عندك اولا الاقسام للتطبيق تختاري منها بالتحريك لليمين ثم قسمين عبارة عن رسائل بتتغير كل شوية المطلوب عشان تظهر انك تخدشي عليها من اليمين للشمال وحتلاقي ورق الهدايا بيختفي كذلك لما بتضغطي علي صورة البروفايل حتفتح معاكي القائمة الجانبية وحتلاقي فيهاالاعدادات استمتعي بالرحلة يا عسل '),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

 
  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _loadIndices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentQuoteIndex = (prefs.getInt('quoteIndex') ?? 0) % quotes.length;
      _currentChallengeIndex =
          (prefs.getInt('challengeIndex') ?? 0) % challenges.length;
 
    });
  }

  void _saveIndices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('quoteIndex', _currentQuoteIndex);
    prefs.setInt('challengeIndex', _currentChallengeIndex);
    prefs.setInt('flitterIndex', _currentFlitterIndex);
  }

  void _checkLastUpdateTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString('lastUpdate') ?? '';
    final lastUpdateTime = DateTime.tryParse(lastUpdate);

    if (lastUpdateTime != null) {
      final now = DateTime.now();
      final difference = now.difference(lastUpdateTime).inHours;

      if (difference >= 24 || isTesting) {
        _updateContent();
      }
    } else {
      _updateContent();
    }
  }

  ValueNotifier<int> updateNotifier = ValueNotifier<int>(0);

  void _updateContent() {
    setState(() {
      _currentQuoteIndex = (_currentQuoteIndex + 1) % quotes.length;
      _currentChallengeIndex = (_currentChallengeIndex + 1) % challenges.length;
   
    });
    _saveIndices();
    _updateLastUpdateTime();

    updateNotifier.value++;
  }

  void _updateLastUpdateTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastUpdate', DateTime.now().toIso8601String());
  }

  void _startTimers() {
    const duration = isTesting ? Duration(minutes: 5) : Duration(hours: 1);
    _timer = Timer.periodic(duration, (timer) {
      _updateContent();
    });
  }

  List<String> destinations = [
    'AzkarScreen',
    'TasksScreen',
    'GoalsScreen',
    'DiaryScreen',

  
    'Selfscreen',
    'Doaascreen'
  ];

  final List<String> quotes = [
    '{لا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا} \n (التوبة: 40)',
    'تذكري أن الصبر مفتاح الفرج',
    'ابتسمي للحياة، فالابتسامة تزرع السعادة حولك',
    'تعلمي من أخطائك ولا تدعيها تعكر مزاجك',
    'كوني مستعدة دائمًا لتحقيق أحلامك',
    'اجعلي الإيمان بنفسك وقدراتك سلاحك الأقوى',
    'تمتعي باللحظات الصعبة لأنها تجعلك أقوى',
    'استمتعي بكل ما تفعلينه وابذلي قصارى جهدك',
    'ابحثي عن الإيجابية في كل شيء من حولك',
    'اعملي على تحقيق أهدافك بثقة وإصرار',
    'كونى من أولئك الذين يعملون بلا كلل ولا ملل',
    'تذكري أن كل يوم هو فرصة جديدة للبداية من جديد',
    'استمعي لقلبك واتبعي أحلامك بشجاعة',
    '{إِنَّ مَعَ الْعُسْرِ يُسْرًا} \n (الشرح: 6)',
    'ابحثي عن الجمال في التفاصيل الصغيرة من حياتك',
    'كوني دائمًا مبتسمة، فالابتسامة سر الجمال',
    'تذكري أن العمل الجاد يؤتي ثماره في النهاية',
    'استمتعي برحلتك نحو النجاح، ليست الوصول فقط هو المهم',
    'اجعلي من الإيجابية نمط حياتك اليومي',
    'كوني مصدر إلهام للنساء من حولك',
    'تعلمي كيف تستفيدين من كل تجربة تمر بها',
    'استثمري في تطوير ذاتك ومهاراتك باستمرار',
    'تحدثي بلطف واعملي على نشر الخير في كل مكان',
    'ابذلي قصارى جهدك في كل ما تفعلينه',
    '{وَتَوَكَّلْ عَلَى اللَّهِ وَكَفَىٰ بِاللَّهِ وَكِيلًا} \n (الأحزاب: 3)',
    'كوني متفائلة دائمًا بمستقبلك وبإمكانياتك',
    'تذكري أن الله معك في كل خطوة تخطوينها',
    'كنِّ جريئة في تحقيق أحلامك وتحقيق أهدافك',
    'احتفظي بروح المغامرة والتجربة في حياتك',
    'ابحثي عن السلام الداخلي والرضا بما لديك',
    'اجعلي العفو والرحمة سمة من سماتك',
    'كوني متفائلة بأن الله يفتح لك أبواب الخير',
    'تذكري أن كل تحدي هو فرصة للنمو والتطور',
    '{وَمَنْ يَتَّقِ اللَّهَ يَجْعَلْ لَهُ مَخْرَجًا} \n (الطلاق: 2)',
    'ابحثي عن الجمال في التفاصيل اليومية من حياتك',
    'تعلمي كيف تديرين وقتك بفعالية وذكاء',
    'ابني علاقات إيجابية ومثمرة مع الأشخاص من حولك',
    'اجعلي العلم والمعرفة رفيقيك في كل مرحلة من حياتك',
    'كوني مثابرة ولا تستسلمي أمام الصعوبات',
    'تذكري أن النجاح يأتي لمن يصبر ويعمل بجدية',
    'استمتعي بالتحديات لأنها تعلمك الكثير عن نفسك',
    'كوني محفزة لنفسك قبل أن تكونين محفزة للآخرين',
    'تذكري أن لديك القدرة على تغيير العالم من حولك',
    'ابني أحلامك بقلب متفائل وعقل مستعد للعمل الجاد',
    'استمعي لنصائح الأشخاص الذين يحبونك ويريدون لك الخير',
    'تعلمي كيف تديرين الضغوطات بفعالية وبدون إرهاق',
    'كوني مبادرة في تحقيق الخير والإحسان للناس',
    '{يَا أَيُّهَا الَّذِينَ آمَنُوا اتَّقُوا اللَّهَ} \n (النساء: 1)',
    'ابحثي عن الفرص الجديدة واستغليها لتحقيق أحلامك',
    'تذكري أن الحياة قصيرة فاجعلي كل لحظة تستحق العيش',
    'استمتعي بمسيرتك الشخصية وكنِّ فخورة بما حققتيه',
    'كوني مثابرة وصبورة في مواجهة التحديات',
    'تذكري أن الله لن يضيع أجر من أحسن عملاً',
    'ابذلي قصارى جهدك في تحقيق أحلامك ولا تيأسي',
    'اجعلي من كل فشل درسًا تستفيدين منه في المستقبل',
    'تعلمي كيف تتعاملين مع النجاح والفشل بروح متفائلة',
    'كوني متواضعة واعترفي بأخطائك لتتعلمي منها',
    'تذكري أن العمل الجماعي يحقق نتائج أكبر وأفضل',
    'استمتعي بمسيرتك العملية وابذلي جهدك لتطويرها',
    'ابحثي عن الإلهام في كل مكان من حولك',
    'كوني صادقة مع نفسك ومع الآخرين في كل تعاملاتك',
    'تذكري أن لديك القدرة على التأثير الإيجابي في العالم',
    'استمعي لرغبات قلبك واتبعي ما يجعلك سعيدة',
    'كوني مستعدة لمواجهة التحديات بروح منتصرة',
    'تعلمي كيف تتغلبين على الخوف وتحققين أهدافك',
    'ابحثي عن السعادة الحقيقية في الأشياء البسيطة',
    'استمعي لصوت داخلك وتبني قراراتك بحكمة',
    'كوني مثابرة ومصممة على تحقيق كل ما تحلمين به',
    'تذكري أن النجاح يحتاج إلى تضحيات وجهد كبير',
    'ابحثي عن السلام الداخلي وابني عليه في كل تجربة',
    'كوني متفائلة دائمًا بأن كل شيء يسير نحو الأفضل',
    'تذكري أن الله لا يضيع أجر المحسنين',
    'استمتعي بكل تفاصيل حياتك ولا تدعي الحزن يسيطر عليكِ',
    'كوني مبادرة في تغيير الأشياء إلى الأفضل',
    'تعلمي كيف تديرين طاقتك الإيجابية وتحافظين عليها',
    'ابني علاقات قوية ومثمرة مع الأشخاص المحيطين بكِ',
    'اجعلي النمو الشخصي هدفًا دائمًا تسعى إليه',
    'ابحثي عن الجمال في الأشياء الصغيرة من حولكِ',
    'تعلمي كيف تتعاملين مع الضغوطات بكل هدوء وثقة',
    'كوني مثابرة وصبورة في سعيك نحو أحلامك',
    'تذكري أن الله مع الصابرين والمحسنين',
    'اجعلي من العلم والمعرفة سلاحك الأقوى في الحياة',
    'استمتعي بكل تجربة تمر بها وابذلي جهدك للاستفادة منها',
    'كوني واثقة من قدراتك وقدراتك على تحقيق النجاح',
    'تذكري أن العمل الجاد يؤدي إلى النجاح المستدام',
    'ابحثي عن السعادة الحقيقية في الرضا بما لديكِ',
    'استمعي لقلبك واتبعي ما يجعلك سعيدة ومحتوية',
    'كوني مثابرة ولا تفقدي الأمل أبدًا',
    'تذكري أن الثقة بالنفس هي أول خطوة نحو النجاح',
    'اجعلي من الإيمان بالله وبقدراتك دافعًا لكل تحدي تواجهينه',
    'تعلمي كيف تديرين الضغوطات بفعالية وسلاسة',
    'كوني متواضعة واستفيدي من كل تجربة تمر بها',
    'تذكري أن لديك القوة للتغلب على أي عقبة تقف أمامكِ',
    'استمتعي برحلتك نحو النجاح ولا تدعي الصعوبات توقفك',
    'كوني مبادرة في مواجهة التحديات وتحويلها إلى فرص للنجاح',
    'تعلمي كيف تتعاملين مع النجاح بروح من التواضع والامتنان',
    'ابحثي عن السعادة في اللحظات البسيطة والجميلة من حياتك',
    'اجعلي من الأخلاق الحسنة سمة رئيسية في شخصيتك',
    'تذكري أن الله يرزق من يشاء بغير حساب',
    'استمتعي بما تفعلينه وابذلي قصارى جهدك في كل مرة',
    'كوني مستعدة لتحقيق أحلامك بشغف وإصرار',
    'تعلمي كيف تتعاملين مع التحديات بروح من الإيمان والصبر',
    'ابحثي عن الإيجابية في كل موقف تمرين به',
    'استمتعي بلحظات النجاح واحتفلي بها بفرح وسرور',
    'تذكري أن لديك القوة لتغيير العالم من حولك بالإيمان والعمل الجاد',
    'اجعلي الأمل والتفاؤل رفيقيك الدائمين في حياتك',
    'تعلمي كيف تديرين الوقت بشكل فعال وذكي',
    'كوني متواضعة في النجاح وكريمة في الفشل',
    'تذكري أن الله مع الصابرين والمتقين',
    'ابحثي عن الحب والخير في تعاملاتك مع الآخرين',
    'استمتعي برحلتك الشخصية وكوني على ثقة بأن كل شيء يسير بالطريق الصحيح',
    'كوني مستعدة لتحقيق كل أحلامك ولا تقفي عند العثرات',
    'تعلمي كيف تديرين الضغوطات بذكاء وهدوء',
    'اجعلي من النمو الشخصي هدفًا دائمًا تسعى إليه',
    'كوني مثابرة ولا تيأسي أبدًا من تحقيق أحلامك',
    'تعلمي كيف تتعاملين مع الفشل بروح من التفاؤل والتجديد',
    'استمتعي بلحظات الفرح والسعادة وابحثي عنها في كل يوم',
    'كوني مستعدة لتحدي نفسك وتجاوز حدودك الشخصية',
    'تذكري أن كل تحدي يمكن أن يكون فرصة جديدة للنجاح',
    'اجعلي من الإيمان بالله وبقدراتك سلاحًا لتحقيق كل ما تحلمين به',
    'ابحثي عن السعادة في الأشياء البسيطة والمفرحة من حياتك',
    'استمتعي بكل لحظة من حياتك واجعليها تساهم في نموك وتطورك',
    'كوني محفزة ومبادرة في كل خطوة تخطوينها',
    'تذكري أن لديك القدرة على تحقيق كل أحلامك بالعمل الجاد والإصرار',
    'استمعي لصوت قلبك واتبعي أحلامك بكل ثقة وقناعة',
    'كوني صادقة مع نفسك ومع الآخرين في كل موقف',
    'تعلمي كيف تتعاملين مع النجاح والفشل بروح من الثقة والحكمة',
    'ابني علاقات إيجابية ومثمرة مع الأشخاص الذين يساعدونك في تحقيق أحلامك',
    'اجعلي من التفاؤل والأمل رفيقيك الدائمين في حياتك',
    'تذكري أن لديك القدرة على تغيير العالم بإيمانك وبعملك الصالح',
    'كوني مستعدة لتحدي كل التحديات وتحويلها إلى فرص للنجاح',
    'استمتعي برحلتك نحو النجاح واعلمي أن كل شيء يأتي في وقته المناسب',
    'كوني مثابرة ومتفائلة بأن كل تحدي يمكنك تجاوزه بنجاح',
    'تعلمي كيف تديرين الوقت بشكل ذكي وفعال',
    'ابحثي عن الجمال والسعادة في كل لحظة من حياتك',
    'تذكري أن العمل الجماعي يحقق نتائج أفضل وأكبر',
    'استمتعي بكل تجربة تمر بها وتعلمي منها لتكوني أقوى',
    'كوني واثقة من قدراتك ومواهبك وابذلي جهدك لتحقيق النجاح',
    'تذكري أن الثقة بالنفس هي المفتاح الأول لتحقيق الأهداف',
    'استمتعي برحلتك الشخصية واجعلي من كل تجربة درسًا للنمو والتطور',
    'كوني مستعدة للتغيير والنمو الشخصي بكل فخر وثقة',
    'ابحثي عن السعادة الحقيقية في الرضا بما لديك وبنعم الله عليك',
    'اجعلي من الصبر والاستمرار سمتين أساسيتين في شخصيتك',
    'تعلمي كيف تتعاملين مع الضغوطات وتحوليها إلى فرص للنمو',
    'كوني متفائلة دائمًا بأن الله معك وسيوفقك في كل خطوة تخطوينها',
    'تذكري أن كل يوم هو فرصة لبداية جديدة وأفضل',
    'استمعي لنصائح الأشخاص المختلفين وتعلمي من خبراتهم المختلفة',
    'كوني مبادرة في تغيير الأشياء إلى الأفضل بإرادتك وتصميمك',
    'تعلمي كيف تديرين الوقت بشكل فعال وتحققين أهدافك بنجاح',
    'ابني علاقات قوية وصداقات مثمرة تساعدك في تحقيق أحلامك',
    'اجعلي العطاء والمساعدة سمة من سمات شخصيتك',
    'تذكري أن النجاح يحتاج إلى صبر وعمل جاد وثقة بالنفس',
    'كوني مثابرة ولا تتوقفي عن المحاولة حتى تنجحي',
    'تعلمي كيف تتعاملين مع التحديات بروح من الثقة والتفاؤل',
    'ابحثي عن السعادة في كل تفاصيل حياتك اليومية',
    'استمتعي بلحظات الفرح والنجاح واحتفلي بها بكل فرح',
    'كوني محفزة لنفسك وللآخرين وحافظي على روح المثابرة',
    'تذكري أن لديك القوة الداخلية لتحقيق كل أحلامك بالعزيمة والإرادة',
    'استمعي لصوت داخلي هادئ واتبعي أحلامك بكل ثقة وقناعة',
    'كوني صادقة مع نفسك ومع الآخرين في كل موقف وتجربة',
    'تعلمي كيف تديرين النجاح والفشل بروح من الثقة والحكمة',
    'ابني علاقات إيجابية ومثمرة مع الأشخاص المحيطين بك',
    'اجعلي من التفاؤل والأمل رفيقيك الدائمين في حياتك',
    'تذكري أن لديك القدرة على تغيير العالم بإيمانك وبعملك الصالح',
    'كوني مستعدة لتحدي كل التحديات وتحويلها إلى فرص للنجاح',
    'استمتعي برحلتك نحو النجاح واعلمي أن كل شيء يأتي في وقته المناسب'
  ];

  final List<String> challenges = [
    'اتحداك \n ان تقراي عشرين صفحة من القران',
    'اتحداك \n ان تمشي لمدة 30 دقيقة',
    'اتحداك \n ان تتعلمى 10 كلمات جديدة في لغة جديدة',
    'اتحداك \n ان تشربى 8 أكواب من الماء',
    'اتحداك \n ان تكتبى صفحة في يومياتك',
    'اتحداك \n ان تقرأى مقالاً في موضوع جديد',
    'اتحداك \n ان تقومى بتمرين رياضي لمدة 15 دقيقة',
    'اتحداك \n ان تتعلمى كيفية طهي وصفة جديدة',
    'اتحداك \n ان تقرأى فصلًا من كتاب تفضله',
    'اتحداك \n ان ترتبى غرفتك',
    'اتحداك \n ان تتصلى بصديق قديم',
    'اتحداك \n ان تكتبى قائمة بأهدافك للأسبوع القادم',
    'اتحداك \n ان تقرأى قصة قصيرة',
    'اتحداك \n ان تتعلمى مهارة جديدة',
    'اتحداك \n ان تستمعى إلى بودكاست تعليمي',
    'اتحداك \n ان تخرجى في نزهة ',
    'اتحداك \n ان ترسمى لمدة 30 دقيقة',
    'اتحداك \n ان تشاهدى وثائقيًا عن موضوع يثير اهتمامك',
    'اتحداك \n ان تقومى بعمل تطوعي',
    'اتحداك \n ان تتناولى وجبة صحية',
    'اتحداك \n ان تقضي ساعة دون استخدام التكنولوجيا',
    'اتحداك \n ان تتعلمى جملة جديدة بلغة أجنبية',
    'اتحداك \n ان تقومى بتنظيف مطبخك',
    'اتحداك \n ان تكتبى رسالة شكر لشخص ما',
    'اتحداك \n ان تستمعى إلى تلخيص كتاب',
    'اتحداك \n ان تشاهدى فيلمًا تعليميًا',
    'اتحداك \n ان تقرأى عن شخصية تاريخية',
    'اتحداك \n ان تذهبى إلى مكان جديد في مدينتك',
    'اتحداك \n ان تقومى بمهمة مؤجلة منذ فترة طويلة',
    'اتحداك \n ان تبدأى مشروعًا او فكرة جديدة',
    'اتحداك \n ان تكتبى قصيدة قصيرة',
    'اتحداك \n ان تتعلم عن ثقافة جديدة',
    'اتحداك \n ان تشاهدى فيديو تعليمي على اليوتيوب',
    'اتحداك \n ان تقرأى فصلًا من كتاب غير خيالي',
    'اتحداك \n ان تخرجى للتنزه مع العائلة',
    'اتحداك \n ان تكتبى قائمة بالأشياء التي تشعر بالامتنان لها',
    'اتحداك \n ان تقومى بزيارة متحف',
    'اتحداك \n ان تطبخى وجبة جديدة',
    'اتحداك \n ان تتعلمى رقصة جديدة',
    'اتحداك \n ان تشاهدى عرضًا مسرحيًا',
    'اتحداك \n ان تقرأى عن مهارة جديدة',
    'اتحداك \n ان تكتبى قصة قصيرة',
    'اتحداك \n ان تقرأى عن علم النفس',
    'اتحداك \n ان تتحدثى مع شخص عن مواضيع عميقة',
    'اتحداك \n ان تتعلمى كيفية الحياكة أو الكروشيه',
    'اتحداك \n ان تقرأى مقالًا علميًا',
    'اتحداك \n ان تكتبى رسالة حب لشخص تحبه',
    'اتحداك \n ان تتعلمى تقنية جديدة على الهاتف',
    'اتحداك \n ان تقرأى كتابًا دينيا',
    'اتحداك \n ان تخرجى لالتقاط صور للطبيعة',
    'اتحداك \n ان تمارسى رياضة جديدة',
    'اتحداك \n ان تكتبى قائمة بأهداف الشهر القادم',
    'اتحداك \n ان تقرأى كتابًا عن تطوير الذات',
    'اتحداك \n ان تتعلمى عن الصحة النفسية',
    'اتحداك \n ان تقرأى مقالًا عن الفضاء',
    'اتحداك \n ان تتعلمى أساسيات التصوير',
    'اتحداك \n ان تكتبى مقالة قصيرة',
    'اتحداك \n ان تقرأى كتابًا عن التاريخ',
    'اتحداك \n ان تتحدثى مع شخص تحبه عن أحلامك',
    'اتحداك \n ان تتعلمى كيفية صنع شيء يدوي',
    'اتحداك \n ان تقرأى عن البيولوجيا',
    'اتحداك \n ان تخرجى للتنزه مع الأصدقاء',
    'اتحداك \n ان تكتبى رسالة إلى نفسك المستقبلية',
    'اتحداك \n ان تقرأى فصلًا من كتاب روائي',
    'اتحداك \n ان تشاركى في دورة تدريبية عبر الإنترنت',
    'اتحداك \n ان تكتبى خطة لتحقيق هدف معين',
    'اتحداك \n ان تقومى بتغيير ديكور غرفتك',
    'اتحداك \n ان تقرأى عن التنمية البشرية',
    'اتحداك \n ان تخرجى للتنزه على الشاطئ',
    'اتحداك \n ان تشاهدى عرضًا كوميديًا',
    'اتحداك \n ان تقرأى كتابًا عن العلوم',
    'اتحداك \n ان تتحدثى مع شخص غريب بلطف',
    'اتحداك \n ان تقومى بترتيب مكتبك',
    'اتحداك \n ان تتعلمى كيفية البرمجة',
    'اتحداك \n انى تقرأ عن الاقتصاد',
    'اتحداك \n ان تخرجى لمشاهدة النجوم',
    'اتحداك \n ان تشاهدى فيديو تعليمي عن الصحة',
    'اتحداك \n ان تتعلمى عن علم الاجتماع',
    'اتحداك \n ان تشاركى في نشاط خيري',
    'اتحداك \n ان تكتبى قائمة بأحلامك المستقبلية',
    'اتحداك \n ان تقرأى فصلًا من كتاب فلسفي',
    'اتحداك \n ان تتحدثى مع شخص عن ثقافته',
    'اتحداك \n ان تشاهدى فيديو عن التكنولوجيا',
    'اتحداك \n ان تخرجى للتنزه في الحديقة',
    'اتحداك \n ان تقرأى كتابًا عن الأدب',
    'اتحداك \n ان تكتبى مقالًا عن موضوع تهتم به',
    'اتحداك \n ان تقومى بترتيب مكتبتك',
    'اتحداك \n ان تخرجى للتنزه على الأقدام',
    'اتحداك \n ان تشاهدى فيلمًا دراميًا',
    'اتحداك \n ان تقرأى كتابًا عن السياسة',
    'اتحداك \n ان تتحدثى مع شخص جديد عن أحلامه',
    'اتحداك \n ان تتعلمى عن الفلسفة',
    'اتحداك \n ان تشاهدى برنامجًا تعليميًا',
    'اتحداك \n ان تتعلمى عن علم النفس',
    'اتحداك \n ان تقرأى كتابًا عن التسويق الدولي',
    'اتحداك \n ان تكتبى قصيدة عن الأحلام',
    'اتحداك \n ان تتعلمى عن الطبخ الصحي',
    'اتحداك \n ان تكتبى مذكرات عن تجربة سفركى الأخيرة',
    'اتحداك \n ان تتعلىم عن علم الأنثروبولوجيا',
    'اتحداك \n ان تقرأى عن علم الفلك',
    'اتحداك \n ان تشاهدى فيلمًا عن التاريخ القديم',
    'اتحداك \n ان تكتبى قصيدة عن الصداقة',
    'اتحداك \n ان تتعلم عن التكنولوجيا المالية',
    'اتحداك \n ان تشاهدى فيلمًا كلاسيكيًا',
    'اتحداك \n ان تكتبى مذكرات عن حدث تاريخي هام في بلدك',
    'اتحداك \n ان تكتبى خاطرة عن الحياة',
    'اتحداك \n ان تكتبى قصيدة عن الحزن',
    'اتحداك \n ان تتعلمى عن التحليل الاقتصادي',
    'اتحداك \n ان تقومى بزيارة متنزه طبيعي',
    'اتحداك \n ان تقرأى عن الطب النفسي',
    'اتحداك \n ان تقرأى عن علم النفس التنظيمي',
    'اتحداك \n ان تشاهدى فيلمًا عن الفضاء والكواكب',
    'اتحداك \n ان تكتبى مذكرات عن تجربة سفر ',
    'اتحداك \n ان تتعلمى عن التسويق الرقمي',
    'اتحداك \n ان تقرأى عن علم الفضاء',
    'اتحداك \n ان تقومى بزيارة للمكتبة ',
    'اتحداك \n ان تكتبى خاطرة عن الأمل',
    'اتحداك \n ان تكتبى قصيدة عن الحزن والفرح',
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const Drawerapp(),
      body: Consumer<Model>(
        builder: (context, model, child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: model.currentBackgrounds['home']!['type'] == 'asset'
                    ? AssetImage(model.currentBackgrounds['home']!['path']!)
                        as ImageProvider
                    : FileImage(
                        File(model.currentBackgrounds['home']!['path']!)),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: double.infinity,
                    height: constraints.maxHeight,
                    child:  Padding(
                          padding: EdgeInsets.only(
                            left: constraints.maxWidth * 0.02,
                            right: constraints.maxWidth * 0.02,
                          ),
                          child: Column(
                            children: [
                              const Header(),
                              Expanded(
                                child: CustomScrollView(
                                  slivers: <Widget>[
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                          return Column(
                                            children: [
                                              SizedBox(
                                                  height:
                                                      constraints.maxHeight *
                                                          0.02),
                                              const Row(
                                                children: [
                                                  Text(
                                                    'Dashboard',
                                                    style: TextStyle(
                                                        fontFamily: 'Roboto',
                                                        fontSize: 24,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  )
                                                ],
                                              ),

                                              // first part-------------------------------------------------------------------
                                              SizedBox(
                                                  height:
                                                      constraints.maxHeight *
                                                          0.01),
                                              SizedBox(
                                                height:
                                                    constraints.maxHeight * 0.3,
                                                child: PageView.builder(
                                                  controller: _pageController,
                                                  itemCount:
                                                      model.dashboards.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    bool isFocused =
                                                        index == _currentPage;
                                                    if (isFocused) {
                                                      _animationController
                                                          .forward();
                                                    } else {
                                                      _animationController
                                                          .reset();
                                                    }
                                                    return AnimatedBuilder(
                                                      animation:
                                                          _pageController,
                                                      builder:
                                                          (context, child) {
                                                        double value = 1.0;
                                                        if (_pageController
                                                            .position
                                                            .haveDimensions) {
                                                          value =
                                                              _pageController
                                                                      .page! -
                                                                  index;
                                                          value = (1 -
                                                                  (value.abs() *
                                                                      0.3))
                                                              .clamp(0.0, 1.0);
                                                        }
                                                        return Center(
                                                          child:
                                                              Transform.scale(
                                                            scale: value,
                                                            child: Opacity(
                                                              opacity: value,
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  switch (
                                                                      destinations[
                                                                          index]) {
                                                                    case 'AzkarScreen':
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => const AzkarScreen()));
                                                                      break;
                                                                        
                                                                    case 'TasksScreen':
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => const TasksScreen()));
                                                                      break;
                                                                    case 'GoalsScreen':
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => const GoalsScreen()));
                                                                      break;
                                                                 
                                                                    case 'DiaryScreen':
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => const DiaryScreen()));
                                                                      break;
                                                                  
                                                                
                                                               
                                                                    case 'Selfscreen':
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => const Selfscreen()));
                                                                      break;
                                                                       case 'Doaascreen':
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => const Doaascreen()));
                                                                      break;
                                                                  }
                                                                },
                                                                child:
                                                                    Container(
                                                                  margin: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10.0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20.0),
                                                                    boxShadow: const [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black26,
                                                                        offset: Offset(
                                                                            0,
                                                                            4),
                                                                        blurRadius:
                                                                            10.0,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: Stack(
                                                                    children: [
                                                                      ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(20.0),
                                                                        child: Image
                                                                            .asset(
                                                                          model
                                                                              .dashboards[index]
                                                                              .image,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          width:
                                                                              double.infinity,
                                                                          height:
                                                                              double.infinity,
                                                                        ),
                                                                      ),
                                                                      if (!isFocused)
                                                                        ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(20.0),
                                                                          child:
                                                                              BackdropFilter(
                                                                            filter:
                                                                                ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                                                            child:
                                                                                Container(
                                                                              color: Colors.black.withOpacity(0.3),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      Positioned(
                                                                        bottom:
                                                                            20,
                                                                        right:
                                                                            10,
                                                                        left:
                                                                            10,
                                                                        child:
                                                                            AnimatedOpacity(
                                                                          opacity: isFocused
                                                                              ? 1.0
                                                                              : 0.0,
                                                                          duration:
                                                                              const Duration(milliseconds: 300),
                                                                          child:
                                                                              SlideTransition(
                                                                            position:
                                                                                _slideAnimation,
                                                                            child:
                                                                                Text(
                                                                              model.dashboards[index].title,
                                                                              style: const TextStyle(
                                                                                color: Colors.white,
                                                                                fontSize: 24,
                                                                                fontWeight: FontWeight.w900,
                                                                                shadows: [
                                                                                  Shadow(
                                                                                    blurRadius: 10.0,
                                                                                    color: Colors.black,
                                                                                    offset: Offset(2, 2),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),

                                              //  secound part ---------------------------------------------------------------------------------------------------------------

                                              SizedBox(
                                                  height:
                                                      constraints.maxHeight *
                                                          0.03),
                                              Image.asset('images/start.png'),
                                              SizedBox(
                                                  height:
                                                      constraints.maxHeight *
                                                          0.03),
                                              const Row(
                                                children: [
                                                  Text(
                                                    'Motivational Quote',
                                                    style: TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 24,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                  height:
                                                      constraints.maxHeight *
                                                          0.01),
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: const Color.fromARGB(
                                                        255,
                                                        208,
                                                        155,
                                                        23), // Golden color
                                                    width: 3.0,
                                                  ),
                                                  color: const Color(0x003d3f68)
                                                      .withOpacity(0.7),
                                                ),
                                                child: ValueListenableBuilder(
                                                  valueListenable:
                                                      updateNotifier,
                                                  builder:
                                                      (context, value, child) {
                                                    return Scratcher(
                                                      key: Key(value
                                                          .toString()),

                                                      brushSize: 30,
                                                      threshold: 50,
                                                      image: const Image(
                                                        image: AssetImage(
                                                            'images/texture2.png'),
                                                      ),
                                                      onChange: (percentage) {},
                                                      onThreshold: () {},
                                                      child: Container(
                                                        width: constraints
                                                                .maxWidth *
                                                            0.9,
                                                        padding:
                                                            EdgeInsets.only(
                                                          top: constraints
                                                                  .maxHeight *
                                                              0.035,
                                                          bottom: constraints
                                                                  .maxHeight *
                                                              0.035,
                                                          left:
                                                              3.0, 
                                                          right:
                                                              3.0,
                                                        ),
                                                        child: Text(
                                                          quotes[
                                                              _currentQuoteIndex],
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontFamily:
                                                                'Roboto',
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              // third part --------------------------------------------------------------------------------------
                                              SizedBox(
                                                  height:
                                                      constraints.maxHeight *
                                                          0.02),
                                              Image.asset('images/line.png'),
                                              SizedBox(
                                                  height:
                                                      constraints.maxHeight *
                                                          0.01),
                                              const Row(
                                                children: [
                                                  Text(
                                                    'Challenge',
                                                    style: TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 24,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                  height:
                                                      constraints.maxHeight *
                                                          0.01),
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: const Color.fromARGB(
                                                        255,
                                                        208,
                                                        155,
                                                        23), 
                                                    width: 3.0,
                                                  ),
                                                  color: const Color(0x003d3f68)
                                                      .withOpacity(0.7),
                                                ),
                                                child: ValueListenableBuilder(
                                                  valueListenable:
                                                      updateNotifier,
                                                  builder:
                                                      (context, value, child) {
                                                    return Scratcher(
                                                      key: Key(value
                                                          .toString()), 
                                                      brushSize: 30,
                                                      threshold: 50,
                                                      image: const Image(
                                                        image: AssetImage(
                                                            'images/texture2.png'),
                                                      ),
                                                      onChange: (percentage) {},
                                                      onThreshold: () {},
                                                      child: Container(
                                                        width: constraints
                                                                .maxWidth *
                                                            0.9,
                                                        padding:
                                                            EdgeInsets.only(
                                                          top: constraints
                                                                  .maxHeight *
                                                              0.035,
                                                          bottom: constraints
                                                                  .maxHeight *
                                                              0.035,
                                                          left:
                                                              3.0, 
                                                          right:
                                                              3.0, 
                                                        ),
                                                        child: Text(
                                                          challenges[
                                                              _currentChallengeIndex],
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontFamily:
                                                                'Roboto',
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                                                     SizedBox(
                                                  height:
                                                      constraints.maxHeight *
                                                          0.02),
                                              Image.asset('images/line.png'),

                                              //fourth part  ------------------------------------------------------------------

                                       
                                            ],
                                          );
                                        },
                                        childCount: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                     
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
