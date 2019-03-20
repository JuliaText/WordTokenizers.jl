using Test
using WordTokenizers

@testset "default behaviour" begin
	str = "Is 9.5 or 525,600 my favorite number?"                
	tokenized = ["Is", "9.5", "or", "525,600", "my", "favorite", "number", "?"]

	@test tokenized == toktok_tokenize(str)           
	
	str = "This \xa1124, is a sentence with weird \u00a2symbols \u2026 appearing everywhere \xbf"
	tokenized = ["This", "\xa1", "124", ",", "is", "a", "sentence", "with", "weird", "\u00a2", "symbols", 
                      "\u2026", "appearing", "everywhere", "\xbf"]
	@test tokenized == toktok_tokenize(str)	   
end

@testset "URL types" begin
    str = "The https://github.com/jonsafari/tok-tok/blob/master/tok-tok.pl is a website with/and/or slashes and sort of weird : things"
    tokenized = ["The", "https://github.com/jonsafari/tok-tok/blob/master/tok-tok.pl", "is", "a", "website", "with/and/or", "slashes", "and", "sort", "of", "weird", ":", "things"]

    @test tokenized == toktok_tokenize(str)
    
    @testset "url_handler 1" begin
        str = "https://example.com:8085"
        tokenized = ["https://example.com", ":", "8085"]
        @test tokenized == toktok_tokenize(str)
    end
    
    @testset "url_handler 2" begin
        str = "https://www.google.com/search?q=example?"
        tokenized = ["https://www.google.com/search?q=example", "?"]
        @test tokenized == toktok_tokenize(str)
    end
    
    @testset "url_handler 3" begin
        str = "https://+/mxl.com, https://google.com"
        tokenized = ["https", "/", "mxl.com", ",", "https://google.com"]
        @test tokenized == toktok_tokenize(str)
    end
    
    
    @testset "url_handler 4" begin
        str = "https://example.com /example"
        tokenized = ["https://example.com", "/", "example"]
        @test tokenized == toktok_tokenize(str)
    end
end

@testset "multi-lingual" begin
    french = "Maître Corbeau, sur un arbre perché,
    Tenait en son bec un fromage.
    Maître Renard, par l’odeur alléché,
    Lui tint à peu près ce langage :
    « Hé ! bonjour, Monsieur du Corbeau.
    Que vous êtes joli ! Que vous me semblez beau !
    Sans mentir, si votre ramage
    Se rapporte à votre plumage,
    Vous êtes le Phénix des hôtes de ces bois. »
    A ces mots le Corbeau ne se sent pas de joie ;
    Et pour montrer sa belle voix,
    Il ouvre un large bec, laisse tomber sa proie.
    Le Renard s’en saisit, et dit : « Mon bon Monsieur,
    Apprenez que tout flatteur
    Vit aux dépens de celui qui l’écoute :
    Cette leçon vaut bien un fromage, sans doute. »
    Le Corbeau, honteux et confus,
    Jura, mais un peu tard, qu’on ne l’y prendrait plus. "

    old_english = "An. M.LXVI. On þyssum geare man halgode þet 
    mynster æt Westmynstre on Cyldamæsse dæg 7 se cyng Eadward forðferde 
    on Twelfts mæsse æfen 7 hine mann bebyrgede on Twelftan mæssedæg innan 
    þære niwa halgodre circean on Westmyntre 7 Harold eorl feng to Englalandes 
    cynerice swa swa se cyng hit him geuðe 7 eac men hine þærto gecuron 7 wæs 
    gebletsod to cynge on Twelftan mæssedæg 7 þa ylcan geare þe he cyng wæs he 
    for ut mid sciphere togeanes Willelme ... 7 þa hwile com Willelm eorl upp æt 
    Hestingan on Sce Michaeles mæssedæg 7 Harold com norðan 7 him wið gefeaht ear 
    þan þe his here com eall 7 þær he feoll 7 his twægen gebroðra Gyrð 7 Leofwine 
    and Willelm þis land geeode 7 com to Westmynstre 7 Ealdred arceb hine to cynge 
    gehalgode 7 menn guldon him gyld 7 gislas sealdon 7 syððan heora land bohtan. "

    farsi = "مادهٔ بیست و ششم
    1) هر کس حق دارد که از آموزش و پرورش بهره‌مند شود.
    آموزش و پرورش لااقل تا حدودی که مربوط بتعلیمات ابتدائی و اساسی است باید
    مجانی باشد. آموزش ابتدائی اجباری است. آموزش حرفه‌ای باید با شرایط تساوی
    کامل بروی همه باز باشد تا همه بنا باستعداد خود بتوانند از آن بهره‌مند گردند.
    2) آموزش و پرورش باید طوری هدایت شود که شخصیت انسانی هر کس را
    بحد اکمل رشد آن برساند و احترام حقوق و آزادی‌های بشر را تقویت کند. آموزش و
    پرورش باید حسن تفاهم، گذشت و احترام عقاید مخالف و دوستی بین تمام ملل و جمعیتهای
    نژادی یا مذهبی و همچنین توسعه فعالیتهای ملل متحد را در راه حفظ صلح تسهیل نماید.
    3) پدر و مادر در انتخاب نوع آموزش و پرورش فرزندان خود نسبت بدیگران اولویت دارند.
    مادهٔ بیست و هفتم
    1) هر کس حق دارد آزادانه در زندگی فرهنگی اجتما
    عی شرکت کند، از فنون و هنرها متمتع گردد و در پیشرفت علمی و فوائد آن سهیم باشد.
    2) هر کس حق دارد از حمایت منافع معنوی و مادی آثار علمی، فرهنگی یا هنری خود برخوردار شود."

    russian = "Лорем ипсум долор сит амет, яуи ин реяуе пертинациа, еа ест яуод ехпетенда 
    витуператорибус. Еум ут дицант граеци саперет, еу тамяуам епицуреи елецтрам сед. Аеяуе анциллае
    пер ид, вим ностер албуциус вивендум ин, цонгуе долоре сит но. Ид еум алияуип интерпретарис, 
    легере пертинах малуиссет ин усу. Еам еу еиус поссе.
    Сеа еи малорум ассентиор. Алии мутат персиус усу но, цу вих ирацундиа цонсететур, цоррумпит 
    форенсибус диссентиунт но иус. Ессе цибо нонумес ин сеа. Доминг еурипидис модератиус сеа ут, 
    алии иллуд граецис ет сед. Цу путент десеруиссе еам."

    spanish = "Mentiría si dijera que era del todo nuevo el sentimiento de que ya no iba a poder
    ser más que lo que era, que era un hombre que había envejecido más de lo que suponía, que había 
    sospechado tener toda la vida por delante y había ido dejando pasar los años a la espera de que 
    llegara su momento, y ahora la tenía a su espalda. La vida pospuesta para cuando las condiciones
    fueran favorables. Vivir en una suerte de provisionalidad que le había empujado a aplazarlo todo.
    Ahora que no tenía futuro alguno, o que éste era una plácida, rutinaria, repetición del presente.
    Ciertas madrugadas le habían enseñado la serenidad de lo irremediable. Despertarse, ventearse como
    un perro la vida, ocuparse de sus asuntillos, sacar provecho de ellos, comer, beber, dormir. Ahora,
    sólo ahora, cuando estaba de verdad solo, sabía que la vida se escapa por las buenas, corre mucho
    "

    chez = "Článek 26
    Každý má právo na vzdělání. Vzdělání nechť je bezplatné, alespoň v počátečních a základních stupních. 
    Základní vzdělání je povinné. Technické a odborné vzdělání budiž všeobecně přístupné a rovněž vyšší 
    vzdělání má být stejně přístupné všem podle schopností.
    Vzdělání má směřovat k plnému rozvoji lidské osobnosti a k posílení úcty k lidským právům a základním svobodám.
    Má napomáhat k vzájemnému porozumění, snášenlivosti a přátelství mezi všemi národy a všemi skupinami rasovými 
    i náboženskými, jakož i k rozvoji činnosti Spojených národů pro zachování míru.
    Rodiče mají přednostní právo volit druh vzdělání pro své děti.
    Článek 27
    Každý má právo svobodně se účastnit kulturního života společnosti, úžívat plodů umění a podílet se na vědeckém
    pokroku a jeho výtěžcích.
    Každý má právo na ochranu morálních a materiálních zájmů, které vyplývají z jeho vědecké, literární nebo umělecké
    tvorby. "

    vietnamese = "Điều 26:
    1) Mọi người đều có quyền được học hành. Phải áp dụng chế độ giáo dục miễn phí, ít nhất là ở bậc tiểu học và 
    giáo dục cơ sở. Giáo dục tiểu học là bắt buộc. Giáo dục kỹ thuật và ngành nghề phải mang tính phổ thông, và 
    giáo dục cao học phải theo nguyên tắc công bằng cho bất cứ ai có đủ khả năng.
    2) Giáo dục phải hướng tới mục tiêu giúp con người phát triển đầy đủ nhân cách và thúc đẩy sự tôn trọng đối với 
    các quyền và tự do cơ bản của con người. Giáo dục phải tăng cường sự hiểu biết, lòng vị tha và tình bằng hữu giữa 
    tất cả các dân tộc, các nhóm tôn giáo và chủng tộc, cũng như phải đẩy mạnh các hoạt động của Liên Hợp Quốc vì mục 
    đích gìn giữ hoà bình.
    3) Cha, mẹ có quyền ưu tiên lựa chọn loại hình giáo dục cho con cái.
    Điều 27:
    1) Mọi người đều có quyền tự do tham gia vào đời sống văn hoá của cộng đồng, được thưởng thức nghệ thuật và chia 
    xẻ những thành tựu và lợi ích của tiến bộ khoa học.
    2) Mọi người đều có quyền được bảo hộ đối với những quyền lợi về vật chất và tinh thần xuất phát từ công trình 
    khoa học, văn học và nhgệ thuật mà người đó là tác giả. "
    
    french_tokenized = ["Maître", "Corbeau", ",", "sur", "un", "arbre", "perché", ",", "Tenait", "en", "son", "bec",
    "un", "fromage.", "Maître", "Renard", ",", "par", "l", "’", "odeur", "alléché", ",", "Lui", "tint", "à", "peu",
    "près", "ce", "langage", ":", "«", "Hé", "!", "bonjour", ",", "Monsieur", "du", "Corbeau.", "Que", "vous", "êtes",
    "joli", "!", "Que", "vous", "me", "semblez", "beau", "!", "Sans", "mentir", ",", "si", "votre", "ramage", "Se",
    "rapporte", "à", "votre", "plumage", ",", "Vous", "êtes", "le", "Phénix", "des", "hôtes", "de", "ces", "bois.",
    "»", "A", "ces", "mots", "le", "Corbeau", "ne", "se", "sent", "pas", "de", "joie", ";", "Et", "pour", "montrer",
    "sa", "belle", "voix", ",", "Il", "ouvre", "un", "large", "bec", ",", "laisse", "tomber", "sa", "proie.", "Le",
    "Renard", "s", "’", "en", "saisit", ",", "et", "dit", ":", "«", "Mon", "bon", "Monsieur", ",", "Apprenez", "que",
    "tout", "flatteur", "Vit", "aux", "dépens", "de", "celui", "qui", "l", "’", "écoute", ":", "Cette", "leçon", "vaut",
    "bien", "un", "fromage", ",", "sans", "doute.", "»", "Le", "Corbeau", ",", "honteux", "et", "confus", ",", "Jura", ",",
    "mais", "un", "peu", "tard", ",", "qu", "’", "on", "ne", "l", "’", "y", "prendrait", "plus.", ]


old_english_tokenized = ["An.", "M.LXVI.", "On", "þyssum", "geare", "man", "halgode", "þet", "mynster", "æt", "Westmynstre",
    "on", "Cyldamæsse", "dæg", "7", "se", "cyng", "Eadward", "forðferde", "on", "Twelfts", "mæsse", "æfen", "7", "hine", "mann",
    "bebyrgede", "on", "Twelftan", "mæssedæg", "innan", "þære", "niwa", "halgodre", "circean", "on", "Westmyntre", "7", "Harold",
    "eorl", "feng", "to", "Englalandes", "cynerice", "swa", "swa", "se", "cyng", "hit", "him", "geuðe", "7", "eac", "men", "hine",
    "þærto", "gecuron", "7", "wæs", "gebletsod", "to", "cynge", "on", "Twelftan", "mæssedæg", "7", "þa", "ylcan", "geare", "þe",
    "he", "cyng", "wæs", "he", "for", "ut", "mid", "sciphere", "togeanes", "Willelme", "...", "7", "þa", "hwile", "com", "Willelm",
    "eorl", "upp", "æt", "Hestingan", "on", "Sce", "Michaeles", "mæssedæg", "7", "Harold", "com", "norðan", "7", "him", "wið", "gefeaht",
    "ear", "þan", "þe", "his", "here", "com", "eall", "7", "þær", "he", "feoll", "7", "his", "twægen", "gebroðra", "Gyrð", "7", "Leofwine",
    "and", "Willelm", "þis", "land", "geeode", "7", "com", "to", "Westmynstre", "7", "Ealdred", "arceb", "hine", "to", "cynge", "gehalgode",
    "7", "menn", "guldon", "him", "gyld", "7", "gislas", "sealdon", "7", "syððan", "heora", "land", "bohtan.", ]


russian_tokenized = ["Лорем", "ипсум", "долор", "сит", "амет", ",", "яуи", "ин", "реяуе", "пертинациа", ",", "еа",
    "ест", "яуод", "ехпетенда", "витуператорибус.", "Еум", "ут", "дицант", "граеци", "саперет", ",", "еу", "тамяуам",
    "епицуреи", "елецтрам", "сед.", "Аеяуе", "анциллае", "пер", "ид", ",", "вим", "ностер", "албуциус", "вивендум",
    "ин", ",", "цонгуе", "долоре", "сит", "но.", "Ид", "еум", "алияуип", "интерпретарис", ",", "легере", "пертинах",
    "малуиссет", "ин", "усу.", "Еам", "еу", "еиус", "поссе.", "Сеа", "еи", "малорум", "ассентиор.", "Алии", "мутат",
    "персиус", "усу", "но", ",", "цу", "вих", "ирацундиа", "цонсететур", ",", "цоррумпит", "форенсибус", "диссентиунт",
    "но", "иус.", "Ессе", "цибо", "нонумес", "ин", "сеа.", "Доминг", "еурипидис", "модератиус", "сеа", "ут", ",", "алии",
    "иллуд", "граецис", "ет", "сед.", "Цу", "путент", "десеруиссе", "еам.", ]


spanish_tokenized = ["Mentiría", "si", "dijera", "que", "era", "del", "todo", "nuevo", "el", "sentimiento", "de", "que",
    "ya", "no", "iba", "a", "poder", "ser", "más", "que", "lo", "que", "era", ",", "que", "era", "un", "hombre", "que",
    "había", "envejecido", "más", "de", "lo", "que", "suponía", ",", "que", "había", "sospechado", "tener", "toda", "la",
    "vida", "por", "delante", "y", "había", "ido", "dejando", "pasar", "los", "años", "a", "la", "espera", "de", "que",
    "llegara", "su", "momento", ",", "y", "ahora", "la", "tenía", "a", "su", "espalda.", "La", "vida", "pospuesta", "para",
    "cuando", "las", "condiciones", "fueran", "favorables.", "Vivir", "en", "una", "suerte", "de", "provisionalidad", "que",
    "le", "había", "empujado", "a", "aplazarlo", "todo.", "Ahora", "que", "no", "tenía", "futuro", "alguno", ",", "o", "que",
    "éste", "era", "una", "plácida", ",", "rutinaria", ",", "repetición", "del", "presente.", "Ciertas", "madrugadas", "le",
    "habían", "enseñado", "la", "serenidad", "de", "lo", "irremediable.", "Despertarse", ",", "ventearse", "como", "un",
    "perro", "la", "vida", ",", "ocuparse", "de", "sus", "asuntillos", ",", "sacar", "provecho", "de", "ellos", ",", "comer",
    ",", "beber", ",", "dormir.", "Ahora", ",", "sólo", "ahora", ",", "cuando", "estaba", "de", "verdad", "solo", ",", "sabía",
    "que", "la", "vida", "se", "escapa", "por", "las", "buenas", ",", "corre", "mucho", ]


farsi_tokenized = ["مادهٔ", "بیست", "و", "ششم", "1", ")", "هر", "کس", "حق", "دارد", "که", "از", "آموزش", "و",
    "پرورش", "بهره‌مند", "شود.", "آموزش", "و", "پرورش", "لااقل", "تا", "حدودی", "که", "مربوط", "بتعلیمات", "ابتدائی",
    "و", "اساسی", "است", "باید", "مجانی", "باشد.", "آموزش", "ابتدائی", "اجباری", "است.", "آموزش", "حرفه‌ای",
    "باید", "با", "شرایط", "تساوی", "کامل", "بروی", "همه", "باز", "باشد", "تا", "همه", "بنا", "باستعداد",
    "خود", "بتوانند", "از", "آن", "بهره‌مند", "گردند.", "2", ")", "آموزش", "و", "پرورش", "باید", "طوری",
    "هدایت", "شود", "که", "شخصیت", "انسانی", "هر", "کس", "را", "بحد", "اکمل", "رشد", "آن", "برساند", "و",
    "احترام", "حقوق", "و", "آزادی‌های", "بشر", "را", "تقویت", "کند.", "آموزش", "و", "پرورش", "باید", "حسن", "تفاهم",
    "،", "گذشت", "و", "احترام", "عقاید", "مخالف", "و", "دوستی", "بین", "تمام", "ملل", "و", "جمعیتهای", "نژادی",
    "یا", "مذهبی", "و", "همچنین", "توسعه", "فعالیتهای", "ملل", "متحد", "را", "در", "راه", "حفظ", "صلح", "تسهیل",
    "نماید.", "3", ")", "پدر", "و", "مادر", "در", "انتخاب", "نوع", "آموزش", "و", "پرورش", "فرزندان", "خود", "نسبت",
    "بدیگران", "اولویت", "دارند.", "مادهٔ", "بیست", "و", "هفتم", "1", ")", "هر", "کس", "حق", "دارد", "آزادانه", "در",
    "زندگی", "فرهنگی", "اجتما", "عی", "شرکت", "کند", "،", "از", "فنون", "و", "هنرها", "متمتع", "گردد", "و",
    "در", "پیشرفت", "علمی", "و", "فوائد", "آن", "سهیم", "باشد.", "2", ")", "هر", "کس", "حق", "دارد", "از",
    "حمایت", "منافع", "معنوی", "و", "مادی", "آثار", "علمی", "،", "فرهنگی", "یا", "هنری", "خود", "برخوردار", "شود.", ]


chez_tokenized = ["Článek", "26", "Každý", "má", "právo", "na", "vzdělání.", "Vzdělání", "nechť", "je", "bezplatné", 
    ",", "alespoň", "v", "počátečních", "a", "základních", "stupních.", "Základní", "vzdělání", "je", "povinné.", "Technické",
    "a", "odborné", "vzdělání", "budiž", "všeobecně", "přístupné", "a", "rovněž", "vyšší", "vzdělání", "má", "být", "stejně",
    "přístupné", "všem", "podle", "schopností.", "Vzdělání", "má", "směřovat", "k", "plnému", "rozvoji", "lidské", "osobnosti",
    "a", "k", "posílení", "úcty", "k", "lidským", "právům", "a", "základním", "svobodám.", "Má", "napomáhat", "k", "vzájemnému",
    "porozumění", ",", "snášenlivosti", "a", "přátelství", "mezi", "všemi", "národy", "a", "všemi", "skupinami", "rasovými", "i",
    "náboženskými", ",", "jakož", "i", "k", "rozvoji", "činnosti", "Spojených", "národů", "pro", "zachování", "míru.", "Rodiče", "mají",
    "přednostní", "právo", "volit", "druh", "vzdělání", "pro", "své", "děti.", "Článek", "27", "Každý", "má", "právo", "svobodně", "se",
    "účastnit", "kulturního", "života", "společnosti", ",", "úžívat", "plodů", "umění", "a", "podílet", "se", "na", "vědeckém", "pokroku",
    "a", "jeho", "výtěžcích.", "Každý", "má", "právo", "na", "ochranu", "morálních", "a", "materiálních", "zájmů", ",", "které", "vyplývají",
    "z", "jeho", "vědecké", ",", "literární", "nebo", "umělecké", "tvorby.", ]


vietnamese_tokenized = ["Điều", "26", ":", "1", ")", "Mọi", "người", "đều", "có", "quyền", "được", "học", "hành.", "Phải", "áp", "dụng",
    "chế", "độ", "giáo", "dục", "miễn", "phí", ",", "ít", "nhất", "là", "ở", "bậc", "tiểu", "học", "và", "giáo", "dục", "cơ", "sở.", "Giáo",
    "dục", "tiểu", "học", "là", "bắt", "buộc.", "Giáo", "dục", "kỹ", "thuật", "và", "ngành", "nghề", "phải", "mang", "tính", "phổ", "thông", ",", "và",
    "giáo", "dục", "cao", "học", "phải", "theo", "nguyên", "tắc", "công", "bằng", "cho", "bất", "cứ", "ai", "có", "đủ", "khả", "năng.", "2",
    ")", "Giáo", "dục", "phải", "hướng", "tới", "mục", "tiêu", "giúp", "con", "người", "phát", "triển", "đầy", "đủ", "nhân", "cách", "và",
    "thúc", "đẩy", "sự", "tôn", "trọng", "đối", "với", "các", "quyền", "và", "tự", "do", "cơ", "bản", "của", "con", "người.", "Giáo", "dục",
    "phải", "tăng", "cường", "sự", "hiểu", "biết", ",", "lòng", "vị", "tha", "và", "tình", "bằng", "hữu", "giữa", "tất", "cả", "các", "dân",
    "tộc", ",", "các", "nhóm", "tôn", "giáo", "và", "chủng", "tộc", ",", "cũng", "như", "phải", "đẩy", "mạnh", "các", "hoạt", "động", "của",
    "Liên", "Hợp", "Quốc", "vì", "mục", "đích", "gìn", "giữ", "hoà", "bình.", "3", ")", "Cha", ",", "mẹ", "có", "quyền", "ưu", "tiên", "lựa",
    "chọn", "loại", "hình", "giáo", "dục", "cho", "con", "cái.", "Điều", "27", ":", "1", ")", "Mọi", "người", "đều", "có", "quyền", "tự", "do",
    "tham", "gia", "vào", "đời", "sống", "văn", "hoá", "của", "cộng", "đồng", ",", "được", "thưởng", "thức", "nghệ", "thuật", "và", "chia", "xẻ",
    "những", "thành", "tựu", "và", "lợi", "ích", "của", "tiến", "bộ", "khoa", "học.", "2", ")", "Mọi", "người", "đều", "có", "quyền", "được", "bảo",
    "hộ", "đối", "với", "những", "quyền", "lợi", "về", "vật", "chất", "và", "tinh", "thần", "xuất", "phát", "từ", "công", "trình", "khoa", "học", ",",
    "văn", "học", "và", "nhgệ", "thuật", "mà", "người", "đó", "là", "tác", "giả.", ]


    
     languages = [french, old_english, russian, spanish, farsi, chez, vietnamese]
     languages_tokenized = [french_tokenized, old_english_tokenized, russian_tokenized, spanish_tokenized, farsi_tokenized, chez_tokenized, vietnamese_tokenized]

    for ind  in 1 : length(languages)
        @test toktok_tokenize(languages[ind]) == languages_tokenized[ind]
    end
end


@testset "final periods" begin
    @testset "final period 1" begin
        str = "example... sentence1.."
        tokenized = ["example...", "sentence", "1", ".."]
        @test tokenized == toktok_tokenize(str)
        
        str = "example... sentence1."
        tokenized = ["example...", "sentence", "1", "."]
        @test tokenized == toktok_tokenize(str)
    end
    
    @testset "final period 2" begin
        str = "1)example sentence. 2)example sentence.   ‘ "
        tokenized = [".", "‘", "1", ")", "example", "sentence.", "2", ")", "example", "sentence"]
        @test tokenized == toktok_tokenize(str)
        
        str = "1)example sentence. 2)example sentence...   ‘ "
        tokenized = ["1", ")", "example", "sentence.", "2", ")", "example", "sentence...", "‘"]
        @test tokenized == toktok_tokenize(str)
    end
end


@testset "repeated_sequences" begin
    str = "tokenize this ,,, --- ..."
    tokenized = ["tokenize", "this", ",", ",", ",", "---", "..."]
    @test tokenized == toktok_tokenize(str)
end
