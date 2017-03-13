﻿// Структура колонок загружаемых реквизитов, с описанием их свойств
Перем Колонки;

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
	
	ЗаписыватьОбъект = истина;
	ПерваяСтрокаДанныхТабличногоДокумента =2;
	
	КоличествоЭлементов = ТабличныйДокумент.ВысотаТаблицы - ПерваяСтрокаДанныхТабличногоДокумента + 1;
	Если КоличествоЭлементов <= 0 Тогда
		Предупреждение("Нет данных для загрузки");
		Возврат Ложь;
	КонецЕсли;
	ТекстВопросаИсточника = " строк в Платежные Поручения Исходящие";
	
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
			
			если НЕ СоздатьППИсходящее(ТабличныйДокумент, ТекущаяСтрока)Тогда
				
				Отказ = Истина;
				Сообщить("Строка "+ Строка(Загружено + 2)+ " НЕ ЗАГРУЖЕНА!");   //
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

Функция СоздатьППИсходящее(ТабличныйДокумент, ТекущаяСтрока)	
	Перем ПараметрОбъектКопирования;
	Источник = новый массив;	
	
	N_кредита	= формат(ТекущаяСтрока.N_кредита,"ЧЦ=5; ЧГ=0");
	КодПоЕДРПОУ	= формат(ТекущаяСтрока.ИННЗаемщика,"ЧЦ=13; ЧДЦ=2");
	ФИО	= формат(ТекущаяСтрока.ФИО,"ЧЦ=13; ЧГ=0");
	ДатаВыдачиКредита = ДатаИзСтроки10(	формат(ТекущаяСтрока.ДатаВыдачиКредита,"ДФ=""дд.ММ.гггг""")) + 39600;
	СуммаКредита =	формат(ТекущаяСтрока.СуммаКредита,"ЧЦ=7; ЧГ=2");
	Попытка	
		Контрагент  = Справочники.Контрагенты.НайтиПоРеквизиту("КодПоЕДРПОУ",КодПоЕДРПОУ);
		если Контрагент =  Справочники.Контрагенты.ПустаяСсылка() Тогда
			//Создаем контрагента
			
			НовыйКонтрагент = Новый Структура("ЮрФизЛицо, Наименование, НаименованиеПолное, ИНН, КодПоЕДРПОУ , Родитель");
			
			НовыйКонтрагент.ЮрФизЛицо = Перечисления.ЮрФизЛицо.ФизЛицо;
			НовыйКонтрагент.Наименование = ФИО;
			НовыйКонтрагент.НаименованиеПолное = ФИО; 
			НовыйКонтрагент.ИНН =  КодПоЕДРПОУ;
			НовыйКонтрагент.КодПоЕДРПОУ = КодПоЕДРПОУ;
			НовыйКонтрагент.Родитель = Справочники.Контрагенты.НайтиПоНаименованию("Онлайн");
			
			Контрагент = СоздатьНовогоКонтрагента(НовыйКонтрагент).Ссылка; 
			
			Если Контрагент = 0 Тогда
				ВызватьИсключение("Не удалось создать нового контрагента");
			Иначе 
				//Добавляем Схему Налогообложения Контрагентов
				НаборЗаписей = РегистрыСведений.СхемыНалогообложенияКонтрагентов.СоздатьНаборЗаписей();
				
				НаборЗаписей.Отбор.Контрагент.Установить(Контрагент);
				НаборЗаписей.Отбор.Период.Установить(НачалоМесяца(ДатаВыдачиКредита));
				НаборЗаписей.Прочитать();                 
				
				Если НаборЗаписей.Количество() = 0 Тогда
				НовЗапись = НаборЗаписей.Добавить();
				НовЗапись.Контрагент = Контрагент;
				НовЗапись.Период  = НачалоМесяца(ДатаВыдачиКредита);
			    ИначеЕсли НаборЗаписей.Количество() = 1 Тогда
      			НаборЗаписей = НаборЗаписей[0];
    			КонецЕсли;
				НовЗапись.СхемаНалогообложения = Справочники.СхемыНалогообложения.НеПлательщик;
				НаборЗаписей.Записать(Истина);
				
				//Создаем договор
				НовыйДоговорКонтрагента = Новый Структура("Владелец, ВалютаВзаиморасчетов, ВедениеВзаиморасчетов, Организация, ВидДоговора, Дата , Номер, Наименование, СхемаНалоговогоУчета, ВедениеВзаиморасчетов, СложныйНалоговыйУчет,  НеОтноситьНаЗатратыПоНУ , ВидДоговораПоГК, ФормаРасчетов");
				НовыйДоговорКонтрагента.Владелец =  Контрагент;
				НовыйДоговорКонтрагента.ВалютаВзаиморасчетов =  Константы.ВалютаРегламентированногоУчета.Получить();
				НовыйДоговорКонтрагента.ВедениеВзаиморасчетов =   Перечисления.ВедениеВзаиморасчетовПоДоговорам.ПоДоговоруВЦелом;
				НовыйДоговорКонтрагента.Организация =  Справочники.Организации.НайтиПоКоду("000000006");//ОбщегоНазначения.ГоловнаяОрганизация(глЗначениеПеременной("ОсновнаяОрганизация"));
				НовыйДоговорКонтрагента.ВидДоговора =  Перечисления.ВидыДоговоровКонтрагентов.Прочее;
				НовыйДоговорКонтрагента.Дата =  ДатаВыдачиКредита;
				НовыйДоговорКонтрагента.Номер =  N_кредита;
				НовыйДоговорКонтрагента.Наименование =  N_кредита;
				НовыйДоговорКонтрагента.СхемаНалоговогоУчета =  Справочники.СхемыНалоговогоУчетаПоДоговорамКонтрагентов.ПоПервомуСобытию;
				НовыйДоговорКонтрагента.ВедениеВзаиморасчетов =  Перечисления.ВедениеВзаиморасчетовПоДоговорам.ПоДоговоруВЦелом;
				НовыйДоговорКонтрагента.СложныйНалоговыйУчет =  Ложь;
				НовыйДоговорКонтрагента.НеОтноситьНаЗатратыПоНУ =  Ложь;
				НовыйДоговорКонтрагента.ВидДоговораПоГК =  Справочники.ВидыДоговоровПоГК.Поставка;
				НовыйДоговорКонтрагента.ФормаРасчетов =   "Оплата з поточного рахунку";
				ДоговорКонтрагента = СоздатьНовыйДоговорКонтрагента(НовыйДоговорКонтрагента);
				
				Если ДоговорКонтрагента= 0 Тогда
					Сообщить("Не удалось создать новый Договор");
					Возврат Ложь;
				КонецЕсли;
				НовКонтрагент = Контрагент.ПолучитьОбъект();
				НовКонтрагент.ОсновнойДоговорКонтрагента =  ДоговорКонтрагента.Ссылка;
				НовКонтрагент.Записать();
			КонецЕсли;
		Иначе	
			
			ДоговорКонтрагента = Справочники.ДоговорыКонтрагентов.НайтиПоНаименованию(N_кредита);
			если ДоговорКонтрагента =  Справочники.ДоговорыКонтрагентов.ПустаяСсылка() Тогда
				//Создаем договор
				НовыйДоговорКонтрагента = Новый Структура("Владелец, ВалютаВзаиморасчетов, ВедениеВзаиморасчетов, Организация, ВидДоговора, Дата , Номер, Наименование, СхемаНалоговогоУчета, ВедениеВзаиморасчетов, СложныйНалоговыйУчет, НеОтноситьНаЗатратыПоНУ , ВидДоговораПоГК, ФормаРасчетов");
				НовыйДоговорКонтрагента.Владелец =  Контрагент;
				НовыйДоговорКонтрагента.ВалютаВзаиморасчетов =  Константы.ВалютаРегламентированногоУчета.Получить();
				НовыйДоговорКонтрагента.ВедениеВзаиморасчетов =   Перечисления.ВедениеВзаиморасчетовПоДоговорам.ПоДоговоруВЦелом;
				НовыйДоговорКонтрагента.Организация =  Справочники.Организации.НайтиПоКоду("000000006");//ОбщегоНазначения.ГоловнаяОрганизация(глЗначениеПеременной("ОсновнаяОрганизация"));
				НовыйДоговорКонтрагента.ВидДоговора =  Перечисления.ВидыДоговоровКонтрагентов.Прочее;
				НовыйДоговорКонтрагента.Дата =  ДатаВыдачиКредита;
				НовыйДоговорКонтрагента.Номер =  N_кредита;
				НовыйДоговорКонтрагента.Наименование =  N_кредита;
				НовыйДоговорКонтрагента.СхемаНалоговогоУчета =  Справочники.СхемыНалоговогоУчетаПоДоговорамКонтрагентов.ПоПервомуСобытию;
				НовыйДоговорКонтрагента.ВедениеВзаиморасчетов =  Перечисления.ВедениеВзаиморасчетовПоДоговорам.ПоДоговоруВЦелом;
				НовыйДоговорКонтрагента.СложныйНалоговыйУчет =  Ложь;
				НовыйДоговорКонтрагента.НеОтноситьНаЗатратыПоНУ =  Ложь;
				НовыйДоговорКонтрагента.ВидДоговораПоГК =  Справочники.ВидыДоговоровПоГК.Поставка;
				НовыйДоговорКонтрагента.ФормаРасчетов =   "Оплата з поточного рахунку";
				ДоговорКонтрагента = СоздатьНовыйДоговорКонтрагента(НовыйДоговорКонтрагента);
				
				Если ДоговорКонтрагента= 0 Тогда
					ВызватьИсключение("Не удалось создать новый Договор");
				КонецЕсли;
				НовКонтрагент = Контрагент.ПолучитьОбъект();
				НовКонтрагент.ОсновнойДоговорКонтрагента =  ДоговорКонтрагента.Ссылка;
				НовКонтрагент.Записать();
		Иначе	
					ВызватьИсключение("Договор с номером "+N_кредита+" уже существует");
			КонецЕсли
			
		КонецЕсли;
		
		ТекПользователь = ПараметрыСеанса.ТекущийПользователь;
		
		НовыйДокППИх      = Документы.ПлатежноеПоручениеИсходящее.СоздатьДокумент();
		НовыйДокППИх.ВидОперации = Перечисления.ВидыОперацийППИсходящее.РасчетыПоКредитамИЗаймамСКонтрагентами;
		НовыйДокППИх.СчетБанк = ПланыСчетов.Хозрасчетный.НайтиПоКоду("3131");
		
		УправлениеДенежнымиСредствами.ЗаполнитьРеквизитыРасчетногоДокумента(НовыйДокППИх, глЗначениеПеременной("глТекущийПользователь"), Константы.ВалютаРегламентированногоУчета.Получить(), НовыйДокППИх.РасшифровкаПлатежа, ПараметрОбъектКопирования);
		
		Если ПараметрОбъектКопирования = Неопределено Тогда
		Если НовыйДокППИх.Организация.Пустая() Тогда
			НовыйДокППИх.СчетОрганизации = Справочники.БанковскиеСчета.ПустаяСсылка();		
		КонецЕсли;	
		Если НовыйДокППИх.Контрагент.Пустая() Тогда
			НовыйДокППИх.СчетКонтрагента = Справочники.БанковскиеСчета.ПустаяСсылка();
		КонецЕсли;
			
			Для каждого СтрокаПлатеж Из НовыйДокППИх.РасшифровкаПлатежа Цикл
				УправлениеДенежнымиСредствами.УстановитьСтатьюДДСПоУмолчанию(СтрокаПлатеж,НовыйДокППИх.ВидОперации);
			КонецЦикла; 
			СтрокаПлатеж = НовыйДокППИх.РасшифровкаПлатежа[0];
			
		КонецЕсли;
		
		ОбщегоНазначения.ЗаполнитьОбязательныеРеквизитыШапкиНовогоДокумента(НовыйДокППИх, глЗначениеПеременной("глТекущийПользователь"));
		

		НовыйДокППИх.СуммаДокумента  = СуммаКредита;
		НовыйДокППИх.Дата =  ДатаВыдачиКредита;
		НовыйДокППИх.ДатаОплаты =    НовыйДокППИх.Дата;
		НовыйДокППИх.Контрагент = Контрагент;
		НовыйДокППИх.Организация = Справочники.Организации.НайтиПоКоду("000000006");
		НовыйДокППИх.ДоговорКонтрагента = ДоговорКонтрагента;
		НовыйДокППИх.СчетОрганизации = Справочники.БанковскиеСчета.НайтиПоРеквизиту("НомерСчета","292479037" );  
		Если НЕ ЗначениеЗаполнено(НовыйДокППИх.СчетБанк) Тогда
			НовыйДокППИх.СчетБанк=ПланыСчетов.Хозрасчетный.ДругиеСчетаВБанкеВНациональнойВалюте;    // ТекущиеСчетаВНациональнойВалюте 311> ДругиеСчетаВБанкеВНациональнойВалюте 313 
		КонецЕсли;
		
		НоваяРасшифровкаПлатежа = НовыйДокППИх.РасшифровкаПлатежа.Получить(0);
		НоваяРасшифровкаПлатежа.ДоговорКонтрагента = ДоговорКонтрагента.Ссылка;
		НоваяРасшифровкаПлатежа.СтатьяДвиженияДенежныхСредств  = Справочники.СтатьиДвиженияДенежныхСредств.НайтиПоНаименованию("Расчеты по кредитам и займам с контрагентами" );
		НоваяРасшифровкаПлатежа.СчетУчетаРасчетовСКонтрагентом  = ПланыСчетов.Хозрасчетный.НайтиПоКоду("37712");
		

		НоваяРасшифровкаПлатежа.КурсВзаиморасчетов  = 1;
		НоваяРасшифровкаПлатежа.СуммаПлатежа  =  СуммаКредита;
		НоваяРасшифровкаПлатежа.КратностьВзаиморасчетов  = 1;
		НоваяРасшифровкаПлатежа.СуммаВзаиморасчетов  =  СуммаКредита;
		
		НовыйДокППИх.Оплачено = Истина;
		НовыйДокППИх.Ответственный = ТекПользователь;
		НовыйДокППИх.Комментарий = "видача кредита";
		
		НовыйДокППИх.Записать(РежимЗаписиДокумента.Проведение);
		
	Исключение
		Сообщить(ОписаниеОшибки());
		Возврат Ложь;
		
	КонецПопытки;
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
	НовыйДоговорКонтрагента.ВедениеВзаиморасчетов= СтруктураСправочника.ВедениеВзаиморасчетов;
	НовыйДоговорКонтрагента.СложныйНалоговыйУчет= СтруктураСправочника.СложныйНалоговыйУчет;
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

Функция ДатаИзСтроки10(стрДата) экспорт // "01.12.2011" преобразует в '01.12.2011 0:00:00' 
	Попытка 
		возврат Дата(Сред(стрДата,7,4)+Сред(стрДата,4,2)+Лев(стрДата,2)) 
	Исключение 
		возврат '00010101' 
	КонецПопытки; 
КонецФункции // ДатаИзСтроки10()

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
	Колонка.Вставить("ИмяРеквизита","N_кредита");
	Колонка.Вставить("ОписаниеТипов",  ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(5,0));
	//Колонка.Вставить("ШиринаКолонки",  10);
	Колонки.Вставить(Колонка.ИмяРеквизита,Колонка);
	НомерКолонки = НомерКолонки + 1;
	
	Колонка = Новый Структура;
	Колонка.Вставить("НомерКолонки",НомерКолонки);
	Колонка.Вставить("ИмяРеквизита","ИННЗаемщика");
	Колонка.Вставить("ОписаниеТипов",  ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(13,0));
	//Колонка.Вставить("ШиринаКолонки",  10);
	Колонки.Вставить(Колонка.ИмяРеквизита,Колонка);
	НомерКолонки = НомерКолонки + 1;
	
	Колонка = Новый Структура;
	Колонка.Вставить("НомерКолонки",НомерКолонки);
	Колонка.Вставить("ИмяРеквизита","ФИО");
	Колонка.Вставить("ОписаниеТипов",  ОбщегоНазначения.ПолучитьОписаниеТиповСтроки(0));
	//Колонка.Вставить("ШиринаКолонки",  10);
	Колонки.Вставить(Колонка.ИмяРеквизита,Колонка);
	НомерКолонки = НомерКолонки + 1;
	
	Колонка = Новый Структура;
	Колонка.Вставить("НомерКолонки",НомерКолонки);
	Колонка.Вставить("ИмяРеквизита","ДатаВыдачиКредита");
	Колонка.Вставить("ОписаниеТипов",  ОбщегоНазначения.ПолучитьОписаниеТиповДаты(ЧастиДаты.Дата));
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

