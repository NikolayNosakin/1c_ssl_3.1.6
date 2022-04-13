﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

#Область Общее

// Проверяет состояние подсистемы.
// Возвращаемое значение:
//  Булево - Истина включен, Ложь выключен.
//
Функция ЦентрМониторингаВключен() Экспорт
	ПараметрыЦентраМониторинга = Новый Структура("ВключитьЦентрМониторинга, ЦентрОбработкиИнформацииОПрограмме");
	ПараметрыЦентраМониторинга = ЦентрМониторингаСлужебный.ПолучитьПараметрыЦентраМониторингаВнешнийВызов(ПараметрыЦентраМониторинга);	
	Возврат ПараметрыЦентраМониторинга.ВключитьЦентрМониторинга ИЛИ ПараметрыЦентраМониторинга.ЦентрОбработкиИнформацииОПрограмме;
КонецФункции

// Включает подсистему ЦентрМониторинга.
//
Процедура ВключитьПодсистему() Экспорт
    
    ПараметрыЦентраМониторинга = ЦентрМониторингаСлужебный.ПолучитьПараметрыЦентраМониторинга();
    
    ПараметрыЦентраМониторинга.ВключитьЦентрМониторинга = Истина;
	ПараметрыЦентраМониторинга.ЦентрОбработкиИнформацииОПрограмме = Ложь;
    
    ЦентрМониторингаСлужебный.УстановитьПараметрыЦентраМониторингаВнешнийВызов(ПараметрыЦентраМониторинга);
	РегЗадание = ЦентрМониторингаСлужебный.ПолучитьРегламентноеЗаданиеВнешнийВызов("СборИОтправкаСтатистики", Истина);
	ЦентрМониторингаСлужебный.УстановитьРасписаниеПоУмолчаниюВнешнийВызов(РегЗадание);
    
КонецПроцедуры

// Отключает подсистему ЦентрМониторинга.
//
Процедура ОтключитьПодсистему() Экспорт
    
    ПараметрыЦентраМониторинга = ЦентрМониторингаСлужебный.ПолучитьПараметрыЦентраМониторинга();
    
    ПараметрыЦентраМониторинга.ВключитьЦентрМониторинга = Ложь;
	ПараметрыЦентраМониторинга.ЦентрОбработкиИнформацииОПрограмме = Ложь;
	
    ЦентрМониторингаСлужебный.УстановитьПараметрыЦентраМониторингаВнешнийВызов(ПараметрыЦентраМониторинга);
	ЦентрМониторингаСлужебный.УдалитьРегламентноеЗаданиеВнешнийВызов("СборИОтправкаСтатистики");
    
КонецПроцедуры

// Возвращает строковое представление идентификатора информационной базы в центре мониторинга.
// Возвращаемое значение:
//  Строка - уникальный идентификатор информационной базы в центре мониторинга.
//
Функция ИдентификаторИнформационнойБазы() Экспорт
	
	ПараметрыДляПолучения = Новый Структура;
	ПараметрыДляПолучения.Вставить("ВключитьЦентрМониторинга");
	ПараметрыДляПолучения.Вставить("ЦентрОбработкиИнформацииОПрограмме");
	ПараметрыДляПолучения.Вставить("ОзнакомительныйПакетОтправлен");
	ПараметрыДляПолучения.Вставить("НомерКрайнегоПакета");
	ПараметрыДляПолучения.Вставить("ИдентификаторИнформационнойБазы");
	ПараметрыЦентраМониторинга = ЦентрМониторингаСлужебный.ПолучитьПараметрыЦентраМониторинга(ПараметрыДляПолучения);
	
	Если (ПараметрыЦентраМониторинга.ВключитьЦентрМониторинга ИЛИ ПараметрыЦентраМониторинга.ЦентрОбработкиИнформацииОПрограмме) 
		И ПараметрыЦентраМониторинга.ОзнакомительныйПакетОтправлен Тогда
		Возврат Строка(ПараметрыЦентраМониторинга.ИдентификаторИнформационнойБазы);
	КонецЕсли;
	
	// Если данные никогда не отправляли, тогда вернем пустую строку.
	Возврат "";	
	
КонецФункции

#КонецОбласти

#Область БизнесСтатистика

// Записывает операцию бизнес статистики.
//
// Параметры:
//  ИмяОперации	- Строка	- имя операции статистики, в случае отсутствия создается новое.
//  Значение	- Число		- количественное значение операции статистики.
//  Комментарий	- Строка	- произвольный комментарий.
//  Разделитель	- Строка	- разделитель значений в ИмяОперации, если разделитель не точка.
//
Процедура ЗаписатьОперациюБизнесСтатистики(ИмяОперации, Значение, Комментарий = Неопределено, Разделитель = ".") Экспорт
	Если ЗаписыватьОперацииБизнесСтатистики() Тогда
		РегистрыСведений.БуферОперацийСтатистики.ЗаписатьОперациюБизнесСтатистики(ИмяОперации, Значение, Комментарий, Разделитель);
	КонецЕсли;
КонецПроцедуры

// Записывает уникальную операцию бизнес статистики в разрезе часа.
// При записи проверяет уникальность.
//
// Параметры:
//  ИмяОперации      - Строка - имя операции статистики, в случае отсутствия создается новое.
//  КлючУникальности - Строка - ключ для контроля уникальности записи, максимальная длина 100.
//  Значение         - Число  - количественное значение операции статистики.
//  Замещать         - Булево - определяет режим замещения существующей записи.
//                              Истина - перед записью существующая запись будет удалена.
//                              Ложь - если запись уже существует, новые данные игнорируются.
//                              Значение по умолчанию: Ложь.
//
Процедура ЗаписатьОперациюБизнесСтатистикиЧас(ИмяОперации, КлючУникальности, Значение, Замещать = Ложь) Экспорт
    
    ПараметрыЗаписи = Новый Структура("ИмяОперации, КлючУникальности, Значение, Замещать, ТипЗаписи, ПериодЗаписи");
    ПараметрыЗаписи.ИмяОперации = ИмяОперации;
    ПараметрыЗаписи.КлючУникальности = КлючУникальности;
    ПараметрыЗаписи.Значение = Значение;
    ПараметрыЗаписи.Замещать = Замещать;
    ПараметрыЗаписи.ТипЗаписи = 1;
    ПараметрыЗаписи.ПериодЗаписи = НачалоЧаса(ТекущаяУниверсальнаяДата());
    
    ЦентрМониторингаСлужебный.ЗаписатьОперациюБизнесСтатистикиСлужебная(ПараметрыЗаписи);
    
КонецПроцедуры

// Записывает уникальную операцию бизнес статистики в разрезе суток.
// При записи проверяет уникальность.
//
// Параметры:
//  ИмяОперации      - Строка - имя операции статистики, в случае отсутствия создается новое.
//  КлючУникальности - Строка - ключ для контроля уникальности записи, максимальная длина 100.
//  Значение         - Число  - количественное значение операции статистики.
//  Замещать         - Булево - определяет режим замещения существующей записи.
//                              Истина - перед записью существующая запись будет удалена.
//                              Ложь - если запись уже существует, новые данные игнорируются.
//                              Значение по умолчанию: Ложь.
//
Процедура ЗаписатьОперациюБизнесСтатистикиСутки(ИмяОперации, КлючУникальности, Значение, Замещать = Ложь) Экспорт
    
    ПараметрыЗаписи = Новый Структура("ИмяОперации, КлючУникальности, Значение, Замещать, ТипЗаписи, ПериодЗаписи");
    ПараметрыЗаписи.ИмяОперации = ИмяОперации;
    ПараметрыЗаписи.КлючУникальности = КлючУникальности;
    ПараметрыЗаписи.Значение = Значение;
    ПараметрыЗаписи.Замещать = Замещать;
    ПараметрыЗаписи.ТипЗаписи = 2;
    ПараметрыЗаписи.ПериодЗаписи = НачалоДня(ТекущаяУниверсальнаяДата());
   
    ЦентрМониторингаСлужебный.ЗаписатьОперациюБизнесСтатистикиСлужебная(ПараметрыЗаписи);
    
КонецПроцедуры


// Возвращает состояние регистрации бизнес-статистики.
// Возвращаемое значение:
//  Булево - регистрировать бизнес статистику.
//
Функция ЗаписыватьОперацииБизнесСтатистики() Экспорт
	ПараметрыЦентраМониторинга = Новый Структура("ВключитьЦентрМониторинга, ЦентрОбработкиИнформацииОПрограмме, РегистрироватьБизнесСтатистику");
		
	ЦентрМониторингаСлужебный.ПолучитьПараметрыЦентраМониторинга(ПараметрыЦентраМониторинга);
	
	Возврат (ПараметрыЦентраМониторинга.ВключитьЦентрМониторинга ИЛИ ПараметрыЦентраМониторинга.ЦентрОбработкиИнформацииОПрограмме) И ПараметрыЦентраМониторинга.РегистрироватьБизнесСтатистику;
КонецФункции

#КонецОбласти

#Область СтатистикаКонфигурации

// Записывает статистику по объектам конфигурации.
//
// Параметры:
//  СоответствиеИменМетаданных - Структура:
//   * Ключ		- Строка - 	имя объекта метаданных.
//   * Значение	- Строка - 	текст запроса выборки данных, обязательно должно
//							присутствовать поле Количество. Если Количество равно нулю,
//                          то запись не происходит.
//
Процедура ЗаписатьСтатистикуКонфигурации(СоответствиеИменМетаданных) Экспорт
	Параметры = Новый Соответствие;
	Для Каждого ТекМетаданные Из СоответствиеИменМетаданных Цикл
		Параметры.Вставить(ТекМетаданные.Ключ, Новый Структура("Запрос, ОперацииСтатистики, ВидСтатистики", ТекМетаданные.Значение,,0));
	КонецЦикла;
	
    Если ОбщегоНазначения.РазделениеВключено() И ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.БазоваяФункциональность") Тогда
        МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
        ОбластьДанныхСтрока = Формат(МодульРаботаВМоделиСервиса.ЗначениеРазделителяСеанса(), "ЧГ=0");
    Иначе
        ОбластьДанныхСтрока = "0";
    КонецЕсли;
	ОбластьДанныхСсылка = РегистрыСведений.ОбластиСтатистики.ПолучитьСсылку(ОбластьДанныхСтрока);
	
	РегистрыСведений.СтатистикаКонфигурации.Записать(Параметры, ОбластьДанныхСсылка);
КонецПроцедуры

// Записывает статистику по объекту конфигурации.
//
// Параметры:
//  ИмяОбъекта -	Строка	- имя операции статистики, в случае отсутствия создается новое.
//  Значение - 		Число	- количественное значение операции статистики. Если значение
//                            равно нулю, то запись не происходит.
//
Процедура ЗаписатьСтатистикуОбъектаКонфигурации(ИмяОбъекта, Значение) Экспорт
    
    Если Значение <> 0 Тогда 
        ОперацияСтатистики = ЦентрМониторингаПовтИсп.ПолучитьСсылкуОперацииСтатистики(ИмяОбъекта);
        
        Если ОбщегоНазначения.РазделениеВключено() И ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.БазоваяФункциональность") Тогда
            МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
            ОбластьДанныхСтрока = Формат(МодульРаботаВМоделиСервиса.ЗначениеРазделителяСеанса(), "ЧГ=0");
        Иначе
            ОбластьДанныхСтрока = "0";
        КонецЕсли;
        ОбластьДанныхСсылка = РегистрыСведений.ОбластиСтатистики.ПолучитьСсылку(ОбластьДанныхСтрока);
        
        НаборЗаписей = РегистрыСведений.СтатистикаКонфигурации.СоздатьНаборЗаписей();
        НаборЗаписей.Отбор.ОперацияСтатистики.Установить(ОперацияСтатистики);
        
        НовЗапись = НаборЗаписей.Добавить();
        НовЗапись.ИдентификаторОбластиСтатистики = ОбластьДанныхСсылка;
        НовЗапись.ОперацияСтатистики = ОперацияСтатистики;
        НовЗапись.Значение = Значение;	
        НаборЗаписей.Записать(Истина);
    КонецЕсли;
    
КонецПроцедуры

#КонецОбласти

#КонецОбласти
