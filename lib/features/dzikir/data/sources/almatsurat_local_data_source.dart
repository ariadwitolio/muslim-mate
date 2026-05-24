import 'package:muslim_mate/features/dzikir/domain/entities/almatsurat_item.dart';

class AlMatsuratLocalDataSource {
    List<AlMatsuratItem> getItems() => almatsuratItems;
}

const List<AlMatsuratItem> almatsuratItems = [
  AlMatsuratItem(
    id: 1,
    title: "Ta'awudz",
    arabic: 'أَعُوذُ بِاللهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
    transliteration: "A'udzu billahi minasy-syaithanir rajim",
    translation: 'I seek refuge in Allah from the accursed Satan.',
    repeat: 1,
    category: 'morning',
  ),
  AlMatsuratItem(
    id: 2,
    title: 'Al-Fatihah',
    arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ﴿١﴾ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ﴿٢﴾ الرَّحْمَٰنِ الرَّحِيمِ ﴿٣﴾ مَالِكِ يَوْمِ الدِّينِ ﴿٤﴾ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ﴿٥﴾ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ﴿٦﴾ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ ﴿٧﴾',
    transliteration:
        "Bismillāhir-raḥmānir-raḥīm. Al-ḥamdu lillāhi rabbil-'ālamīn. Ar-raḥmānir-raḥīm. Māliki yawmid-dīn. Iyyāka na'budu wa iyyāka nasta'īn. Ihdinash-shirāṭal-mustaqīm. Shirāṭal-ladhīna an'amta 'alayhim ghayril-maghdūbi 'alayhim wa lad-dāllīn.",
    translation:
        'In the name of Allah, the Entirely Merciful, the Especially Merciful. All praise is due to Allah, Lord of all the worlds. The Entirely Merciful, the Especially Merciful. Sovereign of the Day of Recompense. It is You we worship and You we ask for help. Guide us to the straight path — the path of those upon whom You have bestowed favor, not of those who have evoked anger or of those who are astray.',
    repeat: 1,
    category: 'morning',
  ),
  AlMatsuratItem(
    id: 3,
    title: 'Al-Baqarah 1-5',
    arabic:
        'الم ﴿١﴾ ذَٰلِكَ الْكِتَابُ لَا رَيْبَ فِيهِ هُدًى لِّلْمُتَّقِينَ ﴿٢﴾ الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ ﴿٣﴾ وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ ﴿٤﴾ أُولَٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ وَأُولَٰئِكَ هُمُ الْمُفْلِحُونَ ﴿٥﴾',
    transliteration:
        "Alif lām mīm. Dhālikal-kitābu lā rayba fīh, hudan lil-muttaqīn. Alladhīna yu'minūna bil-ghaybi wa yuqīmūnaṣ-ṣalāta wa mimmā razaqnāhum yunfiqūn. Walladhīna yu'minūna bimā unzila ilayka wa mā unzila min qablik, wa bil-ākhirati hum yūqinūn. Ulā'ika 'alā hudan mir-rabbihim wa ulā'ika humul-mufliḥūn.",
    translation:
        'Alif Lam Mim. This is the Book about which there is no doubt, a guidance for those conscious of Allah — who believe in the unseen, establish prayer, and spend out of what We have provided for them, and who believe in what has been revealed to you and what was revealed before you, and of the Hereafter they are certain. Those are upon guidance from their Lord, and it is those who are successful.',
    repeat: 1,
    category: 'morning',
  ),
  AlMatsuratItem(
    id: 4,
    title: 'Ayat Kursi',
    arabic:
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ وَلَا يَئُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    transliteration:
        "Allāhu lā ilāha illā huw, al-ḥayyul-qayyūm, lā ta'khudhuhu sinatun wa lā nawm, lahu mā fis-samāwāti wa mā fil-arḍ, man dhal-ladhī yashfa'u 'indahu illā bi'idhnih, ya'lamu mā bayna aydīhim wa mā khalfahum, wa lā yuḥīṭūna bishay'in min 'ilmihi illā bimā shā', wasi'a kursiyyuhus-samāwāti wal-arḍ, wa lā ya'ūdhuhu ḥifẓuhumā, wa huwal-'aliyyul-'aẓīm.",
    translation:
        'Allah — there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.',
    repeat: 1,
    category: 'morning',
  ),
  AlMatsuratItem(
    id: 5,
    title: 'Al-Baqarah 284-286',
    arabic:
        'لِّلَّهِ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ وَإِن تُبْدُوا مَا فِي أَنفُسِكُمْ أَوْ تُخْفُوهُ يُحَاسِبْكُم بِهِ اللَّهُ فَيَغْفِرُ لِمَن يَشَاءُ وَيُعَذِّبُ مَن يَشَاءُ وَاللَّهُ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    transliteration:
        "Lillāhi mā fis-samāwāti wa mā fil-arḍ, wa in tubdū mā fī anfusikum aw tukhfūhu yuḥāsibkum bihillāh, fayaghfiru liman yashā'u wa yu'adhdhibu man yashā', wallāhu 'alā kulli shay'in qadīr.",
    translation:
        'To Allah belongs whatever is in the heavens and whatever is in the earth. Whether you show what is within yourselves or conceal it, Allah will bring you to account for it. Then He will forgive whom He wills and punish whom He wills, and Allah is over all things competent.',
    repeat: 1,
    category: 'morning',
  ),
  AlMatsuratItem(
    id: 6,
    title: 'Al-Ikhlas',
    arabic:
        'قُلْ هُوَ اللَّهُ أَحَدٌ ﴿١﴾ اللَّهُ الصَّمَدُ ﴿٢﴾ لَمْ يَلِدْ وَلَمْ يُولَدْ ﴿٣﴾ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ ﴿٤﴾',
    transliteration:
        "Qul huwallāhu aḥad. Allāhuṣ-ṣamad. Lam yalid wa lam yūlad. Wa lam yakun lahū kufuwan aḥad.",
    translation:
        'Say: He is Allah, the One. Allah, the Eternal Refuge. He neither begets nor is born. Nor is there to Him any equivalent.',
    repeat: 3,
    category: 'morning',
  ),
  AlMatsuratItem(
    id: 7,
    title: 'Al-Falaq',
    arabic:
        'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ﴿١﴾ مِن شَرِّ مَا خَلَقَ ﴿٢﴾ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ﴿٣﴾ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ﴿٤﴾ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ ﴿٥﴾',
    transliteration:
        "Qul a'ūdhu birabbil-falaq. Min sharri mā khalaq. Wa min sharri ghāsiqin idhā waqab. Wa min sharrin-naffāthāti fil-'uqad. Wa min sharri ḥāsidin idhā ḥasad.",
    translation:
        'Say: I seek refuge in the Lord of daybreak. From the evil of that which He created. And from the evil of darkness when it settles. And from the evil of the blowers in knots. And from the evil of an envier when he envies.',
    repeat: 3,
    category: 'morning',
  ),
  AlMatsuratItem(
    id: 8,
    title: 'An-Nas',
    arabic:
        'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ﴿١﴾ مَلِكِ النَّاسِ ﴿٢﴾ إِلَٰهِ النَّاسِ ﴿٣﴾ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ﴿٤﴾ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ﴿٥﴾ مِنَ الْجِنَّةِ وَالنَّاسِ ﴿٦﴾',
    transliteration:
        "Qul a'ūdhu birabbin-nās. Malikin-nās. Ilāhin-nās. Min sharril-waswāsil-khannās. Alladhī yuwaswisu fī ṣudūrin-nās. Minal-jinnati wan-nās.",
    translation:
        'Say: I seek refuge in the Lord of mankind. The Sovereign of mankind. The God of mankind. From the evil of the retreating whisperer. Who whispers in the breasts of mankind. From among the jinn and mankind.',
    repeat: 3,
    category: 'morning',
  ),
  AlMatsuratItem(
    id: 9,
    title: 'Morning Dhikr — Ashhadu',
    arabic:
        'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    transliteration:
        "Aṣbaḥnā wa aṣbaḥal-mulku lillāh, walḥamdu lillāh, lā ilāha illallāhu waḥdahu lā sharīka lah, lahul-mulku wa lahul-ḥamdu wa huwa 'alā kulli shay'in qadīr.",
    translation:
        'We have entered a new morning and the dominion belongs to Allah. All praise is for Allah. There is no deity worthy of worship except Allah alone, with no partners. To Him belongs the dominion and all praise, and He is over all things capable.',
    repeat: 1,
    category: 'morning',
  ),
  AlMatsuratItem(
    id: 10,
    title: 'Sayyidul Istighfar',
    arabic:
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    transliteration:
        "Allāhumma anta rabbī lā ilāha illā ant, khalaqtanī wa ana 'abduk, wa ana 'alā 'ahdika wa wa'dika mastata't, a'ūdhu bika min sharri mā ṣana't, abū'u laka bini'matika 'alayya wa abū'u bidhanbī faghfir lī fa'innahū lā yaghfirudh-dhunūba illā ant.",
    translation:
        'O Allah, You are my Lord. There is no deity worthy of worship except You. You created me and I am Your servant, and I am upon Your covenant and promise as best I can. I seek refuge in You from the evil of what I have done. I acknowledge Your favor upon me and I acknowledge my sin, so forgive me, for indeed none forgives sins except You.',
    repeat: 1,
    category: 'morning',
  ),

  // Evening items share the same sequence with a different dhikr at id 9.
  AlMatsuratItem(
    id: 1,
    title: "Ta'awudz",
    arabic: 'أَعُوذُ بِاللهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
    transliteration: "A'udzu billahi minasy-syaithanir rajim",
    translation: 'I seek refuge in Allah from the accursed Satan.',
    repeat: 1,
    category: 'evening',
  ),
  AlMatsuratItem(
    id: 2,
    title: 'Al-Fatihah',
    arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ﴿١﴾ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ﴿٢﴾ الرَّحْمَٰنِ الرَّحِيمِ ﴿٣﴾ مَالِكِ يَوْمِ الدِّينِ ﴿٤﴾ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ﴿٥﴾ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ﴿٦﴾ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ ﴿٧﴾',
    transliteration:
        "Bismillāhir-raḥmānir-raḥīm. Al-ḥamdu lillāhi rabbil-'ālamīn. Ar-raḥmānir-raḥīm. Māliki yawmid-dīn. Iyyāka na'budu wa iyyāka nasta'īn. Ihdinash-shirāṭal-mustaqīm. Shirāṭal-ladhīna an'amta 'alayhim ghayril-maghdūbi 'alayhim wa lad-dāllīn.",
    translation:
        'In the name of Allah, the Entirely Merciful, the Especially Merciful. All praise is due to Allah, Lord of all the worlds. The Entirely Merciful, the Especially Merciful. Sovereign of the Day of Recompense. It is You we worship and You we ask for help. Guide us to the straight path — the path of those upon whom You have bestowed favor, not of those who have evoked anger or of those who are astray.',
    repeat: 1,
    category: 'evening',
  ),
  AlMatsuratItem(
    id: 3,
    title: 'Al-Baqarah 1-5',
    arabic:
        'الم ﴿١﴾ ذَٰلِكَ الْكِتَابُ لَا رَيْبَ فِيهِ هُدًى لِّلْمُتَّقِينَ ﴿٢﴾ الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ ﴿٣﴾ وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ ﴿٤﴾ أُولَٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ وَأُولَٰئِكَ هُمُ الْمُفْلِحُونَ ﴿٥﴾',
    transliteration:
        "Alif lām mīm. Dhālikal-kitābu lā rayba fīh, hudan lil-muttaqīn. Alladhīna yu'minūna bil-ghaybi wa yuqīmūnaṣ-ṣalāta wa mimmā razaqnāhum yunfiqūn. Walladhīna yu'minūna bimā unzila ilayka wa mā unzila min qablik, wa bil-ākhirati hum yūqinūn. Ulā'ika 'alā hudan mir-rabbihim wa ulā'ika humul-mufliḥūn.",
    translation:
        'Alif Lam Mim. This is the Book about which there is no doubt, a guidance for those conscious of Allah — who believe in the unseen, establish prayer, and spend out of what We have provided for them, and who believe in what has been revealed to you and what was revealed before you, and of the Hereafter they are certain. Those are upon guidance from their Lord, and it is those who are successful.',
    repeat: 1,
    category: 'evening',
  ),
  AlMatsuratItem(
    id: 4,
    title: 'Ayat Kursi',
    arabic:
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ وَلَا يَئُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    transliteration:
        "Allāhu lā ilāha illā huw, al-ḥayyul-qayyūm, lā ta'khudhuhu sinatun wa lā nawm, lahu mā fis-samāwāti wa mā fil-arḍ, man dhal-ladhī yashfa'u 'indahu illā bi'idhnih, ya'lamu mā bayna aydīhim wa khalfahum, wa lā yuḥīṭūna bishay'in min 'ilmihi illā bimā shā', wasi'a kursiyyuhus-samāwāti wal-arḍ, wa lā ya'ūdhuhu ḥifẓuhumā, wa huwal-'aliyyul-'aẓīm.",
    translation:
        'Allah — there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.',
    repeat: 1,
    category: 'evening',
  ),
  AlMatsuratItem(
    id: 5,
    title: 'Al-Baqarah 284-286',
    arabic:
        'لِّلَّهِ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ وَإِن تُبْدُوا مَا فِي أَنفُسِكُمْ أَوْ تُخْفُوهُ يُحَاسِبْكُم بِهِ اللَّهُ فَيَغْفِرُ لِمَن يَشَاءُ وَيُعَذِّبُ مَن يَشَاءُ وَاللَّهُ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    transliteration:
        "Lillāhi mā fis-samāwāti wa mā fil-arḍ, wa in tubdū mā fī anfusikum aw tukhfūhu yuḥāsibkum bihillāh, fayaghfiru liman yashā'u wa yu'adhdhibu man yashā', wallāhu 'alā kulli shay'in qadīr.",
    translation:
        'To Allah belongs whatever is in the heavens and whatever is in the earth. Whether you show what is within yourselves or conceal it, Allah will bring you to account for it. Then He will forgive whom He wills and punish whom He wills, and Allah is over all things competent.',
    repeat: 1,
    category: 'evening',
  ),
  AlMatsuratItem(
    id: 6,
    title: 'Al-Ikhlas',
    arabic:
        'قُلْ هُوَ اللَّهُ أَحَدٌ ﴿١﴾ اللَّهُ الصَّمَدُ ﴿٢﴾ لَمْ يَلِدْ وَلَمْ يُولَدْ ﴿٣﴾ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ ﴿٤﴾',
    transliteration:
        "Qul huwallāhu aḥad. Allāhuṣ-ṣamad. Lam yalid wa lam yūlad. Wa lam yakun lahū kufuwan aḥad.",
    translation:
        'Say: He is Allah, the One. Allah, the Eternal Refuge. He neither begets nor is born. Nor is there to Him any equivalent.',
    repeat: 3,
    category: 'evening',
  ),
  AlMatsuratItem(
    id: 7,
    title: 'Al-Falaq',
    arabic:
        'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ﴿١﴾ مِن شَرِّ مَا خَلَقَ ﴿٢﴾ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ﴿٣﴾ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ﴿٤﴾ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ ﴿٥﴾',
    transliteration:
        "Qul a'ūdhu birabbil-falaq. Min sharri mā khalaq. Wa min sharri ghāsiqin idhā waqab. Wa min sharrin-naffāthāti fil-'uqad. Wa min sharri ḥāsidin idhā ḥasad.",
    translation:
        'Say: I seek refuge in the Lord of daybreak. From the evil of that which He created. And from the evil of darkness when it settles. And from the evil of the blowers in knots. And from the evil of an envier when he envies.',
    repeat: 3,
    category: 'evening',
  ),
  AlMatsuratItem(
    id: 8,
    title: 'An-Nas',
    arabic:
        'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ﴿١﴾ مَلِكِ النَّاسِ ﴿٢﴾ إِلَٰهِ النَّاسِ ﴿٣﴾ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ﴿٤﴾ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ﴿٥﴾ مِنَ الْجِنَّةِ وَالنَّاسِ ﴿٦﴾',
    transliteration:
        "Qul a'ūdhu birabbin-nās. Malikin-nās. Ilāhin-nās. Min sharril-waswāsil-khannās. Alladhī yuwaswisu fī ṣudūrin-nās. Minal-jinnati wan-nās.",
    translation:
        'Say: I seek refuge in the Lord of mankind. The Sovereign of mankind. The God of mankind. From the evil of the retreating whisperer. Who whispers in the breasts of mankind. From among the jinn and mankind.',
    repeat: 3,
    category: 'evening',
  ),
  AlMatsuratItem(
    id: 9,
    title: 'Evening Dhikr',
    arabic:
        'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    transliteration:
        "Amsaynā wa amsal-mulku lillāh, walḥamdu lillāh, lā ilāha illallāhu waḥdahu lā sharīka lah, lahul-mulku wa lahul-ḥamdu wa huwa 'alā kulli shay'in qadīr.",
    translation:
        'We have entered a new evening and the dominion belongs to Allah. All praise is for Allah. There is no deity worthy of worship except Allah alone, with no partners. To Him belongs the dominion and all praise, and He is over all things capable.',
    repeat: 1,
    category: 'evening',
  ),
  AlMatsuratItem(
    id: 10,
    title: 'Sayyidul Istighfar',
    arabic:
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    transliteration:
        "Allāhumma anta rabbī lā ilāha illā ant, khalaqtanī wa ana 'abduk, wa ana 'alā 'ahdika wa wa'dika mastata't, a'ūdhu bika min sharri mā ṣana't, abū'u laka bini'matika 'alayya wa abū'u bidhanbī faghfir lī fa'innahū lā yaghfirudh-dhunūba illā ant.",
    translation:
        'O Allah, You are my Lord. There is no deity worthy of worship except You. You created me and I am Your servant, and I am upon Your covenant and promise as best I can. I seek refuge in You from the evil of what I have done. I acknowledge Your favor upon me and I acknowledge my sin, so forgive me, for indeed none forgives sins except You.',
    repeat: 1,
    category: 'evening',
  ),
];
