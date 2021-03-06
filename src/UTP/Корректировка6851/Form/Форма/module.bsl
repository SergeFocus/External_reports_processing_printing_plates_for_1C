﻿
Процедура КнопкаВыполнитьНажатие(Кнопка)
	ТекПользователь = ПараметрыСеанса.ТекущийПользователь;
	
	Запрос = Новый Запрос;
	
	Запросы = "
	|ВЫБРАТЬ
	|	ХозрасчетныйДвиженияССубконто.СубконтоКт1,
	|	ХозрасчетныйДвиженияССубконто.СубконтоКт2,
	|	ХозрасчетныйДвиженияССубконто.Сумма,
	|	ХозрасчетныйДвиженияССубконто.СчетДт,
	|	ХозрасчетныйДвиженияССубконто.СчетКт,
	|	ХозрасчетныйДвиженияССубконто.СубконтоДт1,
	|	ХозрасчетныйДвиженияССубконто.СубконтоДт2,
	|	ХозрасчетныйДвиженияССубконто.СубконтоДт3
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.ДвиженияССубконто( 
	|     НАЧАЛОПЕРИОДА(&Дата, МЕСЯЦ),   
	|     КОНЕЦПЕРИОДА(&Дата, МЕСЯЦ),  
	|          Организация = &Организация  
	|            И СчетДт = &СчДт
	|            И СчетКт = &СчКт
	|            И Регистратор В
	|			(ВЫБРАТЬ
	|				ПлатежноеПоручениеВходящееРасшифровкаПлатежа.Ссылка
	|			ИЗ
	|				Документ.ПлатежноеПоручениеВходящее.РасшифровкаПлатежа КАК ПлатежноеПоручениеВходящееРасшифровкаПлатежа
	|			ГДЕ
	|				ПлатежноеПоручениеВходящееРасшифровкаПлатежа.СтатьяДвиженияДенежныхСредств = &СтатьяДвиженияДенежныхСредств
	|				)  
	|                , , ) КАК ХозрасчетныйДвиженияССубконто
	|";

	Запрос.УстановитьПараметр("Дата", Дата);
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("СчДт", СчДт);
	Запрос.УстановитьПараметр("СчКт", СчКт);
	Запрос.УстановитьПараметр("СтатьяДвиженияДенежныхСредств", СтатьяДвиженияДенежныхСредств);
	
	Запрос.Текст = Запросы;
	РЗ = Запрос.Выполнить().Выгрузить();
	//НачатьТранзакцию();
	
			ДокОперация = Документы.ОперацияБух.СоздатьДокумент();
			ДокОперация.Дата =  Дата;  
			ДокОперация.Организация = Организация;
			ДокОперация.Ответственный = ТекПользователь;
			ДокОперация.Содержание = "Корректировка 6851";
			ДокОперация.Комментарий = "Корректировка 6851";
			ДокОперация.Записать();
			Операция = ДокОперация.Ссылка;
			РегХозрасчетныйНачислениеПроцентов = РегистрыБухгалтерии.Хозрасчетный.СоздатьНаборЗаписей();
			РегХозрасчетныйНачислениеПроцентов.Отбор.Регистратор.Значение = Операция;
			
	Для Каждого Строка Из РЗ Цикл
		
		РегЗапись = РегХозрасчетныйНачислениеПроцентов.Добавить();
		РегЗапись.Период = Дата;
		РегЗапись.Регистратор = Операция;
		РегЗапись.Организация = Организация;
		РегЗапись.Содержание  = "Корректировка";
		
		РегЗапись.СчетДт = СчКт;
		РегЗапись.СчетКт = СчКт;
		
		ОбщегоНазначения.УстановитьСубконто(РегЗапись.СчетКт, РегЗапись.СубконтоКт, "Контрагенты", Контрагент );
		ОбщегоНазначения.УстановитьСубконто(РегЗапись.СчетКт, РегЗапись.СубконтоКт, "Договоры", Договор);
		
		ОбщегоНазначения.УстановитьСубконто(РегЗапись.СчетДт, РегЗапись.СубконтоДт, "Контрагенты", Строка.СубконтоКт1);
		ОбщегоНазначения.УстановитьСубконто(РегЗапись.СчетДт, РегЗапись.СубконтоДт, "Договоры", Строка.СубконтоКт2);
		
		РегЗапись.Сумма = Строка.Сумма;
		РегХозрасчетныйНачислениеПроцентов.Записать();
		Опер = Операция.ПолучитьОбъект();
		Опер.СуммаОперации = Опер.СуммаОперации + РегЗапись.Сумма;
		Опер.Записать();


	КонецЦикла;	
	//ЗафиксироватьТранзакцию(); 

КонецПроцедуры


Процедура ПередОткрытием(Отказ, СтандартнаяОбработка)
	СчДт = ПланыСчетов.Хозрасчетный.НайтиПоКоду("311");
	СчКт = ПланыСчетов.Хозрасчетный.НайтиПоКоду("6851");
	СтатьяДвиженияДенежныхСредств = Справочники.СтатьиДвиженияДенежныхСредств.НайтиПоКоду("2472");//Факторинг ТОВ ФК"Верона" 27/03/18-Ф от 27.03.2018
	Дата = НачалоДня(ТекущаяДата())+4*60*60;
	Договор = Справочники.ДоговорыКонтрагентов.НайтиПоКоду("000044229");//27/03/18-Ф от 27.03.2018
	Контрагент = Справочники.Контрагенты.НайтиПоКоду("000016493");//ТОВ "ВЕРОНА"ФК
	Организация = ОбщегоНазначения.ГоловнаяОрганизация(глЗначениеПеременной("ОсновнаяОрганизация"));
КонецПроцедуры

