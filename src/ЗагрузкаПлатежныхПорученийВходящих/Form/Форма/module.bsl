﻿// Структура колонок загружаемых реквизитов, с описанием их свойств
Перем Колонки;
Перем ОперацияНачислениеПені;
Перем ОперацияНачислениеПроцентов;
Перем РегХозрасчетныйНачислениеПені;
Перем РегХозрасчетныйНачислениеПроцентов;

// Процедура - обаботчик события, при нажатии на кнопку "Загрузить" Командной панели "ОсновныеДействияФормы"
//
Процедура ОсновныеДействияФормыЗагрузить(Кнопка)
	
	ЗагрузитьДанные(ЭлементыФормы.ТабличныйДокумент, ЭлементыФормы.Индикатор);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////


// Функция выполняет загрузку данных из табличного документа в справочник или табличную часть документа
//
// Параметры:
//  ТабличныйДокумент - ТабличныйДокумент, у которого необходимо сформировать шапку
//  Индикатор         - Элемент управления индикатор, в котором необходимо отображать процент выполнения загрузки
//
// Возвращаемое значение:
//  Истина, если загрузка прошла без ошибок, Ложь - иначе
//
Функция ЗагрузитьДанные(ТабличныйДокумент, Индикатор) Экспорт

 ОперацияНачислениеПені = Неопределено;
 ОперацияНачислениеПроцентов = Неопределено;
 РегХозрасчетныйНачислениеПені = Неопределено;
 РегХозрасчетныйНачислениеПроцентов = Неопределено;

	ЗаписыватьОбъект = истина;
	ПерваяСтрокаДанныхТабличногоДокумента =2;
	
	КоличествоЭлементов = ТабличныйДокумент.ВысотаТаблицы - ПерваяСтрокаДанныхТабличногоДокумента + 1;
	Если КоличествоЭлементов <= 0 Тогда
		Предупреждение("Нет данных для загрузки");
		Возврат Ложь;
	КонецЕсли;
	ТекстВопросаИсточника = " строк в Платежные Поручения Входящие";
	
	Если Вопрос("Загрузить "+КоличествоЭлементов  + ТекстВопросаИсточника, РежимДиалогаВопрос.ДаНет) = КодВозвратаДиалога.Да Тогда
		
		ОчиститьСообщения();
		Сообщить("Выполняется загрузка"+ ТекстВопросаИсточника, СтатусСообщения.Информация);
		Сообщить("Всего: " + КоличествоЭлементов, СтатусСообщения.Информация);
		Сообщить("---------------------------------------------", СтатусСообщения.БезСтатуса);
		Индикатор.Значение = 0;
		Индикатор.МаксимальноеЗначение = КоличествоЭлементов;
		Загружено = 0;
		//Загрузка строк		
		Для НомерСтроки = ПерваяСтрокаДанныхТабличногоДокумента По ТабличныйДокумент.ВысотаТаблицы Цикл
			НомерТекущейСтроки = Индикатор.Значение + 1;
			ТекстыЯчеек = Неопределено;
			Отказ = Ложь;
			ТекущаяСтрока = КонтрольЗаполненияСтроки(ТабличныйДокумент, НомерСтроки, ТекстыЯчеек);
			
			если НЕ СоздатьППВходящее(ТабличныйДокумент, ТекущаяСтрока)Тогда
				
				Отказ = Истина;
				Сообщить("Строка "+ Строка(Загружено+ 2)+ " НЕ ЗАГРУЖЕНА!");   //
				ТабличныйДокумент.Область((Загружено + 2),1).ЦветФона = Новый Цвет(255, 0, 0);  ;
			КонецЕсли;
			
			Если Не Отказ Тогда
				//Сообщить("Добавлена строка: " + (Загружено + 2));
				
			Иначе
				//Сообщить("При добавлении строки " + (Загружено + 2) + " возникли ошибки. ");
				ЗаписыватьОбъект = Ложь;
			КонецЕсли;
			
			Загружено = Загружено + 1;
			
			Индикатор.Значение = Индикатор.Значение + 1;
			ОбработкаПрерыванияПользователя();
			
		КонецЦикла;
		Сообщить("---------------------------------------------", СтатусСообщения.БезСтатуса);
		
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции

Функция СоздатьППВходящее(ТабличныйДокумент, ТекущаяСтрока)	
	Перем ПараметрОбъектКопирования;
	Источник = новый массив;	
	
	ДатаОперации = ПреобразоватьВДату(ТекущаяСтрока.ДатаОперации);
	БухСчет	= формат(ТекущаяСтрока.БухСчет,"ЧЦ=5; ЧГ=0");
	N_кредита	= формат(СтрЗаменить(ТекущаяСтрока.Операция, "приход от контрагента - погашения кредита и процентов, Кредит №", "")  ,"ЧЦ=5; ЧГ=0");// 
	СуммаКредита =	формат(ТекущаяСтрока.СуммаКредита,"ЧЦ=7; ЧГ=2");
	
	Попытка	
		ДоговорКонтрагента = Справочники.ДоговорыКонтрагентов.НайтиПоНаименованию(N_кредита);
		если ДоговорКонтрагента =  Справочники.ДоговорыКонтрагентов.ПустаяСсылка() Тогда
			
			ВызватьИсключение("Не найден Договор " + N_кредита);
		КонецЕсли;		
		Контрагент  = ДоговорКонтрагента.Владелец;
		
		если Контрагент =  Справочники.Контрагенты.ПустаяСсылка() Тогда
			ВызватьИсключение("Договор " +N_кредита+" не имеет контрагента");
		КонецЕсли;	
		
		ТекПользователь = ПараметрыСеанса.ТекущийПользователь;
		
		НовыйДокППВх      = Документы.ПлатежноеПоручениеВходящее.СоздатьДокумент();
		НовыйДокППВх.ВидОперации = Перечисления.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.РасчетыПоКредитамИЗаймам; 
		НовыйДокППВх.СчетБанк = ПланыСчетов.Хозрасчетный.НайтиПоКоду("3132");
		//
		УправлениеДенежнымиСредствами.ЗаполнитьРеквизитыРасчетногоДокумента(НовыйДокППВх, глЗначениеПеременной("глТекущийПользователь"), Константы.ВалютаРегламентированногоУчета.Получить(), ПараметрОбъектКопирования);
		//
		ЗаполнениеДокументов.ЗаполнитьОбязательныеРеквизитыШапкиНовогоДокумента(НовыйДокППВх, глЗначениеПеременной("глТекущийПользователь"));
		//
		НовыйДокППВх.СуммаДокумента  = СуммаКредита;
		НовыйДокППВх.Дата =  ДатаОперации;
		НовыйДокППВх.ДатаВыписки =    ДатаОперации;
		НовыйДокППВх.ДатаВходящегоДокумента =    ДатаОперации;
		
		НовыйДокППВх.Контрагент = Контрагент;
		НовыйДокППВх.ДоговорКонтрагента = ДоговорКонтрагента;
		НовыйДокППВх.СчетОрганизации = Справочники.БанковскиеСчета.НайтиПоНаименованию("Транзит 2 в ""ПРИВАТБАНК"" 3132" );
		//
		НоваяРасшифровкаПлатежа = НовыйДокППВх.РасшифровкаПлатежа.Получить(0);
		НоваяРасшифровкаПлатежа.ДоговорКонтрагента = ДоговорКонтрагента.Ссылка;
		Если БухСчет = "3771" Тогда
			НоваяРасшифровкаПлатежа.СтатьяДвиженияДенежныхСредств  = Справочники.СтатьиДвиженияДенежныхСредств.НайтиПоНаименованию("1111 Погашення кредиту через CreditOn" ); 
			НоваяРасшифровкаПлатежа.СчетУчетаРасчетовСКонтрагентом  = ПланыСчетов.Хозрасчетный.НайтиПоКоду("37712");
			НовыйДокППВх.Комментарий = "погашення кредиту";
		ИначеЕсли  БухСчет = "373"  Тогда  
			НоваяРасшифровкаПлатежа.СтатьяДвиженияДенежныхСредств  = Справочники.СтатьиДвиженияДенежныхСредств.НайтиПоНаименованию("1112 Відсотки за кредитом" ); 
			Если Число(N_кредита) >= 20515 Тогда //З договору № 20515: 3731
			НоваяРасшифровкаПлатежа.СчетУчетаРасчетовСКонтрагентом  = ПланыСчетов.Хозрасчетный.НайтиПоКоду("3731");
			иначе
			НоваяРасшифровкаПлатежа.СчетУчетаРасчетовСКонтрагентом  = ПланыСчетов.Хозрасчетный.НайтиПоКоду("373");
			КонецЕсли;
			НовыйДокППВх.Комментарий = "відсотки за кредитом";    
		ИначеЕсли БухСчет = "374" Тогда 
			НоваяРасшифровкаПлатежа.СтатьяДвиженияДенежныхСредств  = Справочники.СтатьиДвиженияДенежныхСредств.НайтиПоНаименованию("1113 Пені за прострочення кредиту" );     
			Если Число(N_кредита) >= 20515 Тогда  //З договору № 20515: 
			НоваяРасшифровкаПлатежа.СчетУчетаРасчетовСКонтрагентом  = ПланыСчетов.Хозрасчетный.НайтиПоКоду("3741");
			иначе
			НоваяРасшифровкаПлатежа.СчетУчетаРасчетовСКонтрагентом  = ПланыСчетов.Хозрасчетный.НайтиПоКоду("374");
			КонецЕсли;			
			НовыйДокППВх.Комментарий = "штрафні"; 
		Иначе
			ВызватьИсключение("Суб. счет " + БухСчет + " не входит в список");
		КонецЕсли;
		
		НоваяРасшифровкаПлатежа.КурсВзаиморасчетов  = 1;
		НоваяРасшифровкаПлатежа.СуммаПлатежа  =  СуммаКредита;
		НоваяРасшифровкаПлатежа.КратностьВзаиморасчетов  = 1;
		НоваяРасшифровкаПлатежа.СуммаВзаиморасчетов  =  СуммаКредита;
		//
		НовыйДокППВх.Оплачено = Истина;
		НовыйДокППВх.Ответственный = ТекПользователь;
		НовыйДокППВх.Записать(РежимЗаписиДокумента.Проведение);
		
	Исключение
		Сообщить(ОписаниеОшибки());
		Возврат Ложь;
		
	КонецПопытки;
	
	Если  БухСчет = "373"  Тогда
		Если ОперацияНачислениеПроцентов = Неопределено Тогда
			ДокОперация = Документы.ОперацияБух.СоздатьДокумент();
			ДокОперация.Дата =  НачалоДня(ДатаОперации)+4*60*60;  
			ДокОперация.Организация = НовыйДокППВх.Организация;
			ДокОперация.Ответственный = ТекПользователь;
			ДокОперация.Содержание = "начисление процентов";
			ДокОперация.Комментарий = "начисление процентов";
			ДокОперация.СпособЗаполнения = "Вручную";
			ДокОперация.Записать();
			ОперацияНачислениеПроцентов = ДокОперация.Ссылка;
			РегХозрасчетныйНачислениеПроцентов = РегистрыБухгалтерии.Хозрасчетный.СоздатьНаборЗаписей();
			РегХозрасчетныйНачислениеПроцентов.Отбор.Регистратор.Значение = ОперацияНачислениеПроцентов;
			Сообщить("Создана Операция Начисление Процентов за "+ ДокОперация.Дата);
		КонецЕсли; 
		РегЗапись = РегХозрасчетныйНачислениеПроцентов.Добавить();
		РегЗапись.Период = КонецДня(ДатаОперации);
		РегЗапись.Регистратор = ОперацияНачислениеПроцентов;
		РегЗапись.Организация = НовыйДокППВх.Организация;
		РегЗапись.Содержание  = "начисление % по кредиту";
		
			Если Число(N_кредита) >= 20515 Тогда //З договору № 20515: 3731
			РегЗапись.СчетДт = ПланыСчетов.Хозрасчетный.НайтиПоКоду("3731");
			иначе
			РегЗапись.СчетДт = ПланыСчетов.Хозрасчетный.НайтиПоКоду("373");
			КонецЕсли;
		
		РегЗапись.СчетКт =  ПланыСчетов.Хозрасчетный.ДоходОтРеализацииРаботИУслуг; 
		БухгалтерскийУчет.УстановитьСубконто(РегЗапись.СчетДт, РегЗапись.СубконтоДт, "Контрагенты", Контрагент);
		БухгалтерскийУчет.УстановитьСубконто(РегЗапись.СчетДт, РегЗапись.СубконтоДт, "Договоры", ДоговорКонтрагента);
		БухгалтерскийУчет.УстановитьСубконто(РегЗапись.СчетКт, РегЗапись.СубконтоКт, "СтатьиДоходов", Справочники.СтатьиДоходов.НПНК_ДО_ );

		РегЗапись.Сумма = СуммаКредита;
		РегХозрасчетныйНачислениеПроцентов.Записать();
		Опер = ОперацияНачислениеПроцентов.ПолучитьОбъект();
		Опер.СуммаОперации = Опер.СуммаОперации + РегЗапись.Сумма;
		Опер.Записать();
	ИначеЕсли БухСчет = "374" Тогда
		Если ОперацияНачислениеПені = Неопределено Тогда
			ДокОперация = Документы.ОперацияБух.СоздатьДокумент();
			ДокОперация.Дата =  НачалоДня(ДатаОперации)+4*60*60;  
			ДокОперация.Организация = НовыйДокППВх.Организация;
			ДокОперация.Ответственный = ТекПользователь;
			ДокОперация.Содержание = "нарахування пені";
			ДокОперация.Комментарий = "нарахування пені";
			ДокОперация.СпособЗаполнения = "Вручную";
			ДокОперация.Записать();
			ОперацияНачислениеПені = ДокОперация.Ссылка;
			РегХозрасчетныйНачислениеПені = РегистрыБухгалтерии.Хозрасчетный.СоздатьНаборЗаписей();
			РегХозрасчетныйНачислениеПені.Отбор.Регистратор.Значение = ОперацияНачислениеПені;
			
			Сообщить("Создана Операция Начисление Пені за "+ ДокОперация.Дата);
		КонецЕсли; 
		
		РегЗапись = РегХозрасчетныйНачислениеПені.Добавить();
		РегЗапись.Период = КонецДня(ДатаОперации);
		РегЗапись.Регистратор = ОперацияНачислениеПроцентов;
		РегЗапись.Организация = НовыйДокППВх.Организация;
		РегЗапись.Содержание  = "нарахування пені";
		
			Если Число(N_кредита) >= 20515 Тогда  //З договору № 20515: 
			РегЗапись.СчетДт = ПланыСчетов.Хозрасчетный.НайтиПоКоду("3741");
			иначе
			РегЗапись.СчетДт = ПланыСчетов.Хозрасчетный.НайтиПоКоду("374");
			КонецЕсли;			

		РегЗапись.СчетКт = ПланыСчетов.Хозрасчетный.ПолученныеШтрафыПениНеустойки;  // 733>715 ПолученныеШтрафыПениНеустойки
		БухгалтерскийУчет.УстановитьСубконто(РегЗапись.СчетДт, РегЗапись.СубконтоДт, "Контрагенты", Контрагент);
		БухгалтерскийУчет.УстановитьСубконто(РегЗапись.СчетДт, РегЗапись.СубконтоДт, "Договоры", ДоговорКонтрагента);
		БухгалтерскийУчет.УстановитьСубконто(РегЗапись.СчетКт, РегЗапись.СубконтоКт, "СтатьиДоходов", Справочники.СтатьиДоходов.НПНК_ДО_ );

		РегЗапись.Сумма = СуммаКредита;
		РегХозрасчетныйНачислениеПені.Записать();
		Опер = ОперацияНачислениеПені.ПолучитьОбъект();
		Опер.СуммаОперации = Опер.СуммаОперации + РегЗапись.Сумма;
		Опер.Записать();
	КонецЕсли;
	
	
	Возврат Истина;
КонецФункции


&НаСервере
Функция СоздатьНовогоКонтрагента(СтруктураСправочника)
	
	Перем НовыйКонтрагент,СпрПользователи;
	
	СпрКонтрагенты = Справочники.Контрагенты;
	НовыйКонтрагент = СпрКонтрагенты.СоздатьЭлемент();
	НовыйКонтрагент.Наименование = СтруктураСправочника.Наименование;
	НовыйКонтрагент.НаименованиеПолное = СтруктураСправочника.НаименованиеПолное; 
	НовыйКонтрагент.ИНН = СтруктураСправочника.ИНН;
	НовыйКонтрагент.ЮрФизЛицо = СтруктураСправочника.ЮрФизЛицо;
	НовыйКонтрагент.КодПоЕДРПОУ = СтруктураСправочника.КодПоЕДРПОУ;
	НовыйКонтрагент.Родитель = СтруктураСправочника.Родитель;
	Попытка
		НовыйКонтрагент.Записать();
		Возврат НовыйКонтрагент;
	Исключение
		Возврат 0;
	КонецПопытки;
	
КонецФункции    

//
&НаСервере
Функция СоздатьНовыйДоговорКонтрагента(СтруктураСправочника)
	Перем НовыйКонтрагент,СпрПользователи;
	
	СпрДоговорыКонтрагентов = Справочники.ДоговорыКонтрагентов;
	НовыйДоговорКонтрагента = СпрДоговорыКонтрагентов.СоздатьЭлемент();
	
	
	НовыйДоговорКонтрагента.Наименование = СтруктураСправочника.Наименование;
	
	НовыйДоговорКонтрагента.Владелец= СтруктураСправочника.Владелец.Ссылка;
	НовыйДоговорКонтрагента.ВалютаВзаиморасчетов = СтруктураСправочника.ВалютаВзаиморасчетов;
	НовыйДоговорКонтрагента.ВедениеВзаиморасчетов= СтруктураСправочника.ВедениеВзаиморасчетов;
	НовыйДоговорКонтрагента.Организация= СтруктураСправочника.Организация;
	НовыйДоговорКонтрагента.ВидДоговора= СтруктураСправочника.ВидДоговора;
	НовыйДоговорКонтрагента.Дата= СтруктураСправочника.Дата;
	НовыйДоговорКонтрагента.Номер= СтруктураСправочника.Номер;
	НовыйДоговорКонтрагента.Наименование= СтруктураСправочника.Наименование;
	НовыйДоговорКонтрагента.СхемаНалоговогоУчета= СтруктураСправочника.СхемаНалоговогоУчета;
	НовыйДоговорКонтрагента.ВедениеВзаиморасчетовНУ= СтруктураСправочника.ВедениеВзаиморасчетовНУ;
	НовыйДоговорКонтрагента.СложныйНалоговыйУчет= СтруктураСправочника.СложныйНалоговыйУчет;
	НовыйДоговорКонтрагента.УстановленСрокОплаты= СтруктураСправочника.УстановленСрокОплаты;
	НовыйДоговорКонтрагента.НеОтноситьНаЗатратыПоНУ= СтруктураСправочника.НеОтноситьНаЗатратыПоНУ;
	НовыйДоговорКонтрагента.ВидДоговораПоГК= СтруктураСправочника.ВидДоговораПоГК;
	НовыйДоговорКонтрагента.ФормаРасчетов= СтруктураСправочника.ФормаРасчетов;
	
	
	Попытка
		НовыйДоговорКонтрагента.Записать();
		Возврат НовыйДоговорКонтрагента;
	Исключение
		Возврат 0;
	КонецПопытки;
	
	
КонецФункции

// "01.12.2011" преобразует в '01.12.2011 0:00:00'
Функция ДатаИзСтроки10(стрДата) экспорт  
	Попытка 
		возврат Дата(Сред(стрДата,7,4)+Сред(стрДата,4,2)+Лев(стрДата,2)) 
	Исключение 
		возврат '00010101' 
	КонецПопытки; 
КонецФункции // ДатаИзСтроки10()

Функция ПреобразоватьВДату(ИсхСтр)
	Стр = СокрЛП(ИсхСтр);
	ЭтоДата = Найти(Стр,".") или Найти(Стр,"-") или Найти(Стр,"/");
	ЭтоВремя = Найти(Стр,":");
	Если Не ЭтоДата и Не ЭтоВремя Тогда
		Возврат Дата(1,1,1,1,1,1);
	КонецЕсли;
	МассивДат = Новый Массив;
	МассивВремени = Новый Массив;
	врСтр = "";
	Для а = 1 По СтрДлина(Стр) Цикл
		Если (Сред(Стр,а,1) = "." или Сред(Стр,а,1) = "-" или Сред(Стр,а,1) = "/") и ЭтоДата Тогда
			МассивДат.Добавить(Число(врСтр));
			врСтр = "";
		ИначеЕсли Сред(Стр,а,1) = ":" и Не ЭтоДата Тогда
			МассивВремени.Добавить(Число(врСтр));
			врСтр = "";
		ИначеЕсли Сред(Стр,а,1) = " " или КодСимвола(Сред(Стр,а,1))<48 или КодСимвола(Сред(Стр,а,1))>57 Тогда
			Если МассивДат.Количество()>0 и МассивДат.Количество()<3 и врСтр <> "" Тогда
				МассивДат.Добавить(Число(врСтр));
			КонецЕсли;
			ЭтоДата = Ложь;
			врСтр = "";
		Иначе
			врСтр = врСтр + Сред(Стр,а,1);
		КонецЕсли;
	КонецЦикла;
	Если МассивВремени.Количество()>0 и МассивВремени.Количество()<3 и врСтр <> "" Тогда
		МассивВремени.Добавить(Число(врСтр));
	ИначеЕсли МассивДат.Количество()>0 и МассивДат.Количество()<3 и врСтр <> "" Тогда
		МассивДат.Добавить(Число(врСтр));
	КонецЕсли;
	врДень = 0;
	врМесяц = 0;
	врГод = 0;
	Для Каждого дСтр из МассивДат Цикл
		Если врДень <> 0 и врМесяц <> 0 Тогда
			врГод = дСтр;
		ИначеЕсли врГод <> 0 и врМесяц <> 0 Тогда
			врДень = дСтр;
		ИначеЕсли врГод <> 0 или врДень <> 0 Тогда
			врМесяц = дСтр;
		КонецЕсли;
		Если дСтр/100>1 Тогда
			врГод = дСтр;
		КонецЕсли;
		Если врГод = 0 и врДень = 0 Тогда
			врДень = дСтр;
		КонецЕсли;
	КонецЦикла;
	врЧас = 0;
	врМин = 0;
	врСек = 0;
	Для Каждого вСтр из МассивВремени Цикл
		Если врЧас = 0 Тогда
			врЧас = вСтр;
		ИначеЕсли врМин = 0 Тогда
			врМин = вСтр;
		ИначеЕсли врСек = 0 Тогда
			врСек = вСтр;
		КонецЕсли;
	КонецЦикла;
	Если врГод = 0 или врГод > 9999 Тогда
		врГод = 1;
	ИначеЕсли врГод/100<1 Тогда
		врГод = врГод + 2000;
	КонецЕсли;
	
	Если врМесяц = 0 или врМесяц>12 Тогда
		врМесяц = 1;
	КонецЕсли;
	Если врДень = 0 или врДень>31 Тогда
		врДень = 1;
	КонецЕсли;
	Если врЧас>23 Тогда
		врЧас = 0;
	КонецЕсли;
	Если врМин>59 Тогда
		врМин = 0;
	КонецЕсли;
	Если врСек>59 Тогда
		врСек = 0;
	КонецЕсли;
	Возврат Дата(врГод,врМесяц,врДень,врЧас,врМин,врСек);
КонецФункции

// Функция возвращает части представления даты
//
// Параметры:
//  Представление - Представление даты
//
// Возвращаемое значение:
//  массив частей даты
//
Функция ПолучитьЧастиПредставленияДаты(ЗНАЧ Представление)
	
	МассивЧастей = Новый Массив;
	НачалоЦифры = 0;
	Для к = 1 По СтрДлина(Представление) Цикл
		
		Символ = Сред(Представление, к ,1);
		ЭтоЦифра = Символ >= "0" и Символ <= "9";
		
		Если ЭтоЦифра Тогда
			
			Если НачалоЦифры = 0 Тогда
				НачалоЦифры = к;
			КонецЕсли;
			
		Иначе
			
			Если Не НачалоЦифры = 0 Тогда
				МассивЧастей.Добавить(Число(Сред(Представление,НачалоЦифры, к - НачалоЦифры)));
			КонецЕсли;
			
			НачалоЦифры = 0;
		КонецЕсли;
		
	КонецЦикла;
	
	Если Не НачалоЦифры = 0 Тогда
		МассивЧастей.Добавить(Число(Сред(Представление,НачалоЦифры)));
	КонецЕсли;
	
	Возврат МассивЧастей;
КонецФункции // ()

// Процедура формирует структуру колонок загружаемых реквизитов из табличной части "ТаблицаЗагружаемыхРеквизитов"
//
// Параметры:
//  нет
//
Процедура СформироватьСтруктуруКолонок() Экспорт
	
	НомерКолонки = 1;
	Колонки = Новый Структура;
	
	Колонка = Новый Структура;
	Колонка.Вставить("НомерКолонки",НомерКолонки);
	Колонка.Вставить("ИмяРеквизита","ДатаОперации");
	Колонка.Вставить("ОписаниеТипов",  ОбщегоНазначения.ПолучитьОписаниеТиповДаты(ЧастиДаты.ДатаВремя));
	//Колонка.Вставить("ШиринаКолонки",  10);
	Колонки.Вставить(Колонка.ИмяРеквизита,Колонка);
	НомерКолонки = НомерКолонки + 1;
	
	Колонка = Новый Структура;
	Колонка.Вставить("НомерКолонки",НомерКолонки);
	Колонка.Вставить("ИмяРеквизита","БухСчет");
	Колонка.Вставить("ОписаниеТипов",  ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(5,0));
	//Колонка.Вставить("ШиринаКолонки",  10);
	Колонки.Вставить(Колонка.ИмяРеквизита,Колонка);
	НомерКолонки = НомерКолонки + 1;
	
	Колонка = Новый Структура;
	Колонка.Вставить("НомерКолонки",НомерКолонки);
	Колонка.Вставить("ИмяРеквизита","Операция");
	Колонка.Вставить("ОписаниеТипов",  ОбщегоНазначения.ПолучитьОписаниеТиповСтроки(0));
	//Колонка.Вставить("ШиринаКолонки",  10);
	Колонки.Вставить(Колонка.ИмяРеквизита,Колонка);
	НомерКолонки = НомерКолонки + 1;
	
	Колонка = Новый Структура;
	Колонка.Вставить("НомерКолонки",НомерКолонки);
	Колонка.Вставить("ИмяРеквизита","СуммаКредита");
	Колонка.Вставить("ОписаниеТипов",  ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(7,2));
	//Колонка.Вставить("ШиринаКолонки",  10);
	Колонки.Вставить(Колонка.ИмяРеквизита,Колонка);
	НомерКолонки = НомерКолонки + 1;
КонецПроцедуры // ()

// Функция выполняет контроль заполнения строки данных табличного документа
// сообщает об ошибках и устанавливает коментарии к ошибочным ячейкам
//
// Параметры:
//  ТабличныйДокумент - ТабличныйДокумент, у которого необходимо сформировать шапку
//  НомерСтроки       - Число, номер строки табличного документа
//  ТекстыЯчеек    - возвращает массив текстов ячеек строки,
//
// Возвращаемое значение:
//  структура, ключ - Имя загружаемого реквизита, Значение - Значение загружаемого реквизита
//
Функция КонтрольЗаполненияСтроки(ТабличныйДокумент, НомерСтроки, ТекстыЯчеек = Неопределено, КоличествоОшибок = 0)
	
	ТекстыЯчеек = Новый Массив;
	ТекстыЯчеек.Добавить(Неопределено);
	Для к = 1 По ТабличныйДокумент.ШиринаТаблицы Цикл
		ТекстыЯчеек.Добавить(СокрЛП(ТабличныйДокумент.Область("R"+Формат(НомерСтроки,"ЧГ=")+"C"+Формат(К,"ЧГ=")).Текст));
	КонецЦикла;
	
	ТекущаяСтрока     = Новый Структура;
	Для каждого КлючИЗначение Из Колонки Цикл
		
		Колонка = КлючИЗначение.Значение;
		Если Не ОбработатьОбласть(ТабличныйДокумент.Область("R"+Формат(НомерСтроки,"ЧГ=")+"C"+Формат(Колонка.НомерКолонки,"ЧГ=")), Колонка, ТекущаяСтрока, ТекстыЯчеек) Тогда
			КоличествоОшибок = КоличествоОшибок + 1;
		КонецЕсли;
	КонецЦикла;
	Возврат ТекущаяСтрока;
	
КонецФункции

// Процедура выполняет обработку области табличного документа:
// заполняет расшифровку по представлению ячейки в соответствии со структурой загружаемых реквизитов
// сообщает об ошибке и устанавливает коментарий, если ячейка содержит ошибку
//
// Параметры:
//  Область - область табличного документа
//  Колонка - Структура, свойства, в соответствии с которыми необходимо выполнить обработку области
//  ТекущиеДанные  - структура загруженных значений
//  ТекстыЯчеек    - массив текстов ячеек строки
//
Функция ОбработатьОбласть(Область, Колонка, ТекущиеДанные, ТекстыЯчеек)
	
	Представление = Область.Текст;
	Примечание = "";
	
	Результат = СокрЛП(Представление);
	ОписаниеОшибки = "";
	
	ТекущиеДанные.Вставить(Колонка.ИмяРеквизита,Результат);
	
	Область.Расшифровка = Результат;
	Область.Примечание.Текст = Примечание;
	
	Если Не ПустаяСтрока(Примечание) Тогда
		Сообщить("Ячейка["+Область.Имя+"]("+Колонка.ПредставлениеРеквизита+"): " + Примечание);
	КонецЕсли;
	
	Возврат ПустаяСтрока(Примечание);
	
КонецФункции


// Процедура формирует шапку табличного документа, в соответствии с таблицей загружаемых реквизитов
//
// Параметры:
//  ТабличныйДокумент - ТабличныйДокумент, у которого необходимо сформировать шапку
//
Процедура СформироватьШапкуТабличногоДокумента(ТабличныйДокумент) Экспорт
	
	Линия = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная,1);
	
	//Таблица = ТаблицаЗагружаемыхРеквизитов.Скопировать();
	//Таблица.Сортировать("НомерКолонки");
	Для каждого КлючИЗначение Из Колонки Цикл
		ЗагружаемыйРеквизит = КлючИЗначение.Значение;
		НомерКолонки = ЗагружаемыйРеквизит.НомерКолонки;
		//ШиринаКолонки = ЗагружаемыйРеквизит.ШиринаКолонки;
		
		
		Область = ТабличныйДокумент.Область("R1C"+НомерКолонки);
		БылТекст = Не ПустаяСтрока(Область.Текст);
		Область.Текст       = ?(БылТекст,Область.Текст + Символы.ПС,"") + ЗагружаемыйРеквизит.ИмяРеквизита;
		Область.Расшифровка = ЗагружаемыйРеквизит.ИмяРеквизита;
		Область.ЦветФона = ЦветаСтиля.ЦветФонаФормы;
		Область.Обвести(Линия, Линия, Линия, Линия);
		
		//ОбластьКолонки = ТабличныйДокумент.Область("C"+НомерКолонки);
		//ОбластьКолонки.ШиринаКолонки = ?(БылТекст,Макс(ОбластьКолонки.ШиринаКолонки,ШиринаКолонки),ШиринаКолонки);
		
	КонецЦикла;
	
КонецПроцедуры // СформироватьШапкуТабличногоДокумента()


Процедура ПередОткрытием(Отказ, СтандартнаяОбработка)
	СформироватьСтруктуруКолонок();
	СформироватьШапкуТабличногоДокумента(ЭлементыФормы.ТабличныйДокумент);
КонецПроцедуры

