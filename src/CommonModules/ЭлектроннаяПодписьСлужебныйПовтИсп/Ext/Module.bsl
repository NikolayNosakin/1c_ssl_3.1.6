﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Только для внутреннего использования.
// 
// Возвращаемое значение:
//  ФиксированнаяСтруктура:
//   * ИспользоватьЭлектронныеПодписи - Булево
//   * ИспользоватьШифрование - Булево
//   * ПроверятьЭлектронныеПодписиНаСервере - Булево
//   * СоздаватьЭлектронныеПодписиНаСервере - Булево
//   * ЗаявлениеНаВыпускСертификатаДоступно - Булево
//   * ОписанияПрограмм - ФиксированныйМассив из см. ОписаниеПрограммы
//   * ОписанияПрограммПоСсылке - ФиксированноеСоответствие из КлючИЗначение:
//       ** Ключ - СправочникСсылка.ПрограммыЭлектроннойПодписиИШифрования
//       ** Значение - см. ОписаниеПрограммы
//
Функция ОбщиеНастройки() Экспорт
	
	ОбщиеНастройки = Новый Структура;
	
	УстановитьПривилегированныйРежим(Истина);
	
	ОбщиеНастройки.Вставить("ИспользоватьЭлектронныеПодписи",
		Константы.ИспользоватьЭлектронныеПодписи.Получить());
	
	ОбщиеНастройки.Вставить("ИспользоватьШифрование",
		Константы.ИспользоватьШифрование.Получить());
	
	Если ОбщегоНазначения.РазделениеВключено()
	 Или ОбщегоНазначения.ИнформационнаяБазаФайловая()
	   И Не ОбщегоНазначения.КлиентПодключенЧерезВебСервер() Тогда
		
		ОбщиеНастройки.Вставить("ПроверятьЭлектронныеПодписиНаСервере", Ложь);
		ОбщиеНастройки.Вставить("СоздаватьЭлектронныеПодписиНаСервере", Ложь);
	Иначе
		ОбщиеНастройки.Вставить("ПроверятьЭлектронныеПодписиНаСервере",
			Константы.ПроверятьЭлектронныеПодписиНаСервере.Получить());
		
		ОбщиеНастройки.Вставить("СоздаватьЭлектронныеПодписиНаСервере",
			Константы.СоздаватьЭлектронныеПодписиНаСервере.Получить());
	КонецЕсли;
	
	ОбщиеНастройки.Вставить("ЗаявлениеНаВыпускСертификатаДоступно", 
		Метаданные.Обработки.Найти("ЗаявлениеНаВыпускНовогоКвалифицированногоСертификата") <> Неопределено);
	Если ОбщиеНастройки.ЗаявлениеНаВыпускСертификатаДоступно Тогда
		МодульЗаявлениеНаВыпускНовогоКвалифицированногоСертификата = ОбщегоНазначения.ОбщийМодуль("Обработки.ЗаявлениеНаВыпускНовогоКвалифицированногоСертификата");
		ОбщиеНастройки.ЗаявлениеНаВыпускСертификатаДоступно = МодульЗаявлениеНаВыпускНовогоКвалифицированногоСертификата.ЗаявлениеНаВыпускСертификатаДоступно();
	КонецЕсли;		
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Программы.Ссылка КАК Ссылка,
	|	Программы.Наименование КАК Представление,
	|	Программы.ИмяПрограммы КАК ИмяПрограммы,
	|	Программы.ТипПрограммы КАК ТипПрограммы,
	|	Программы.АлгоритмПодписи КАК АлгоритмПодписи,
	|	Программы.АлгоритмХеширования КАК АлгоритмХеширования,
	|	Программы.АлгоритмШифрования КАК АлгоритмШифрования
	|ИЗ
	|	Справочник.ПрограммыЭлектроннойПодписиИШифрования КАК Программы
	|ГДЕ
	|	НЕ Программы.ПометкаУдаления
	|	И НЕ Программы.ЭтоВстроенныйКриптопровайдер
	|
	|УПОРЯДОЧИТЬ ПО
	|	Наименование";
	
	Выборка = Запрос.Выполнить().Выбрать();
	ОписанияПрограмм = Новый Массив;
	ОписанияПрограммПоСсылке = Новый Соответствие;
	ПоставляемыеНастройки = Справочники.ПрограммыЭлектроннойПодписиИШифрования.ПоставляемыеНастройкиПрограмм();
	
	Пока Выборка.Следующий() Цикл
		Отбор = Новый Структура("ИмяПрограммы, ТипПрограммы", Выборка.ИмяПрограммы, Выборка.ТипПрограммы);
		Строки = ПоставляемыеНастройки.НайтиСтроки(Отбор);
		Если Строки.Количество() = 0 Тогда
			Идентификатор = "";
			АлгоритмыПроверкиПодписи = Новый Массив;
		Иначе
			Строка = Строки[0]; // СтрокаТаблицыЗначений: см. ЭлектроннаяПодписьСлужебный.ПоставляемыеНастройкиПрограмм
			Идентификатор = Строка.Идентификатор;
			АлгоритмыПроверкиПодписи = Строка.АлгоритмыПроверкиПодписи;
			Если АлгоритмыПроверкиПодписи.Найти(Строка.АлгоритмПодписи) = Неопределено Тогда
				АлгоритмыПроверкиПодписи.Вставить(0, Строка.АлгоритмПодписи);
			КонецЕсли;
			Для Каждого АлгоритмПодписи Из Строка.АлгоритмыПодписи Цикл
				Если АлгоритмыПроверкиПодписи.Найти(АлгоритмПодписи) = Неопределено Тогда
					АлгоритмыПроверкиПодписи.Добавить(АлгоритмПодписи);
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		
		Описание = ОписаниеПрограммы();
		ЗаполнитьЗначенияСвойств(Описание, Выборка);
		Описание.Идентификатор = Идентификатор;
		Описание.АлгоритмыПроверкиПодписи = АлгоритмыПроверкиПодписи;
		
		ФиксированноеОписание = Новый ФиксированнаяСтруктура(Описание);
		ОписанияПрограмм.Добавить(ФиксированноеОписание);
		ОписанияПрограммПоСсылке.Вставить(Описание.Ссылка, ФиксированноеОписание);
	КонецЦикла;
	
	ОбщиеНастройки.Вставить("ОписанияПрограмм", Новый ФиксированныйМассив(ОписанияПрограмм));
	ОбщиеНастройки.Вставить("ОписанияПрограммПоСсылке", Новый ФиксированноеСоответствие(ОписанияПрограммПоСсылке));
	ОбщиеНастройки.Вставить("ПоставляемыеПутиКМодулямПрограмм",
		Справочники.ПрограммыЭлектроннойПодписиИШифрования.ПоставляемыеПутиКМодулямПрограмм());
	
	ОбщиеНастройки.Вставить("ВерсияНастроек", Строка(Новый УникальныйИдентификатор));
	
	ОбщиеНастройки.Вставить("ДоступнаПроверкаСертификатаВОблачномСервисеСПараметрами", 
		ДоступнаПроверкаСертификатаВОблачномСервисеСПараметрами());
	
	Возврат Новый ФиксированнаяСтруктура(ОбщиеНастройки);
	
КонецФункции

// Возвращаемое значение:
//  Структура:
//   * Ссылка - СправочникСсылка.ПрограммыЭлектроннойПодписиИШифрования
//   * Представление - Строка
//   * ИмяПрограммы - Строка
//   * ТипПрограммы - Число
//   * АлгоритмПодписи - Строка
//   * АлгоритмХеширования - Строка
//   * АлгоритмШифрования - Строка
//   * Идентификатор - Строка
//
Функция ОписаниеПрограммы() Экспорт
	
	Описание = Новый Структура;
	Описание.Вставить("Ссылка");
	Описание.Вставить("Представление");
	Описание.Вставить("ИмяПрограммы");
	Описание.Вставить("ТипПрограммы");
	Описание.Вставить("АлгоритмПодписи");
	Описание.Вставить("АлгоритмХеширования");
	Описание.Вставить("АлгоритмШифрования");
	Описание.Вставить("Идентификатор");
	Описание.Вставить("АлгоритмыПроверкиПодписи");
	
	Возврат Описание;
	
КонецФункции

Функция ТипыВладельцев(ТолькоСсылки = Ложь) Экспорт
	
	Результат = Новый Соответствие;
	Типы = Метаданные.ОпределяемыеТипы.ПодписанныйОбъект.Тип.Типы();
	
	ИсключаемыеТипы = Новый Соответствие;
	ИсключаемыеТипы.Вставить(Тип("Неопределено"), Истина);
	ИсключаемыеТипы.Вставить(Тип("Строка"), Истина);
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РаботаСФайлами") Тогда
		ИсключаемыеТипы.Вставить(Тип("СправочникСсылка." + "ВерсииФайлов"), Истина);
	КонецЕсли;
	
	Для Каждого Тип Из Типы Цикл
		Если ИсключаемыеТипы.Получить(Тип) <> Неопределено Тогда
			Продолжить;
		КонецЕсли;
		Результат.Вставить(Тип, Истина);
		Если Не ТолькоСсылки Тогда
			ИмяТипаОбъекта = СтрЗаменить(Метаданные.НайтиПоТипу(Тип).ПолноеИмя(), ".", "Объект.");
			Результат.Вставить(Тип(ИмяТипаОбъекта), Истина);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

Функция КлассификаторОшибокКриптографии() Экспорт
	
	Возврат ЭлектроннаяПодписьСлужебный.КлассификаторОшибокКриптографии();
	
КонецФункции

Функция ПутиКПрограммамНаСерверахLinux(ИмяКомпьютера) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ИмяКомпьютера", ИмяКомпьютера);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ПутиКПрограмме.Программа,
	|	ПутиКПрограмме.ПутьКПрограмме
	|ИЗ
	|	РегистрСведений.ПутиКПрограммамЭлектроннойПодписиИШифрованияНаСерверахLinux КАК ПутиКПрограмме
	|ГДЕ
	|	ПутиКПрограмме.ИмяКомпьютера = &ИмяКомпьютера";
	
	ПутиКПрограммамНаСерверахLinux = Новый Соответствие;
	УстановитьПривилегированныйРежим(Истина);
	Выборка = Запрос.Выполнить().Выбрать();
	УстановитьПривилегированныйРежим(Ложь);
	Пока Выборка.Следующий() Цикл
		ТекстыОшибок = Новый Массив;
		ОписаниеПути = Новый Структура;
		ОписаниеПути.Вставить("ПутьКПрограмме", Выборка.ПутьКПрограмме);
		ОписаниеПути.Вставить("Существует", ОдинИзМодулейСуществует(Выборка.ПутьКПрограмме, ТекстыОшибок));
		ОписаниеПути.Вставить("ТекстОшибки", ?(ОписаниеПути.Существует, "",
			СтрСоединить(ТекстыОшибок, Символы.ПС)));
		ПутиКПрограммамНаСерверахLinux.Вставить(Выборка.Программа, ОписаниеПути);
	КонецЦикла;
	
	ОбщиеНастройки = ЭлектроннаяПодпись.ОбщиеНастройки();
	ТипПлатформыСтрокой = ЭлектроннаяПодписьСлужебныйКлиентСервер.ТипПлатформыСтрокой();
	
	Для Каждого ОписаниеПрограммы Из ОбщиеНастройки.ОписанияПрограмм Цикл
		Если ПутиКПрограммамНаСерверахLinux.Получить(ОписаниеПрограммы.Ссылка) <> Неопределено Тогда
			Если ЗначениеЗаполнено(ОписаниеПрограммы.Идентификатор) Тогда
				ПутиКПрограммамНаСерверахLinux.Вставить(ОписаниеПрограммы.Идентификатор,
					ПутиКПрограммамНаСерверахLinux.Получить(ОписаниеПрограммы.Ссылка));
			КонецЕсли;
			Продолжить;
		КонецЕсли;
		ОписаниеПути = ОписаниеПутиПоИдентификаторуПрограммы(ОписаниеПрограммы.Идентификатор,
			ОбщиеНастройки.ПоставляемыеПутиКМодулямПрограмм, ТипПлатформыСтрокой);
		Если ОписаниеПути <> Неопределено Тогда
			ПутиКПрограммамНаСерверахLinux.Вставить(ОписаниеПрограммы.Ссылка, ОписаниеПути);
			ПутиКПрограммамНаСерверахLinux.Вставить(ОписаниеПрограммы.Идентификатор, ОписаниеПути);
		КонецЕсли;
	КонецЦикла;
	
	ПоставляемыеНастройки = Справочники.ПрограммыЭлектроннойПодписиИШифрования.ПоставляемыеНастройкиПрограмм();
	Для Каждого ПоставляемаяНастройка Из ПоставляемыеНастройки Цикл
		Если ПутиКПрограммамНаСерверахLinux.Получить(ПоставляемаяНастройка.Идентификатор) <> Неопределено Тогда
			Продолжить;
		КонецЕсли;
		ОписаниеПути = ОписаниеПутиПоИдентификаторуПрограммы(ПоставляемаяНастройка.Идентификатор,
			ОбщиеНастройки.ПоставляемыеПутиКМодулямПрограмм, ТипПлатформыСтрокой);
		Если ОписаниеПути <> Неопределено Тогда
			ПутиКПрограммамНаСерверахLinux.Вставить(ПоставляемаяНастройка.Идентификатор, ОписаниеПути);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(ПутиКПрограммамНаСерверахLinux);
	
КонецФункции

Функция ОписаниеПутиПоИдентификаторуПрограммы(Идентификатор,
			ПоставляемыеПутиКМодулямПрограмм, ТипПлатформыСтрокой)
	
	ОписаниеПути = Неопределено;
	
	Для Каждого ПутиКМодулямПрограмм Из ПоставляемыеПутиКМодулямПрограмм Цикл
		Если Не СтрНачинаетсяС(Идентификатор, ПутиКМодулямПрограмм.Ключ) Тогда
			Продолжить;
		КонецЕсли;
		ПутиКМодулямПрограммы = ПутиКМодулямПрограмм.Значение.Получить(ТипПлатформыСтрокой);
		Если ПутиКМодулямПрограммы = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		ТекстыОшибок = Новый Массив;
		ОписаниеПути = Новый Структура("ПутьКПрограмме, Существует, ТекстОшибки",
			ПутиКМодулямПрограммы[0], Ложь, "");
		Для Каждого ПутиКМодулям Из ПутиКМодулямПрограммы Цикл
			Если Не ОдинИзМодулейСуществует(ПутиКМодулям, ТекстыОшибок) Тогда
				Продолжить;
			КонецЕсли;
			ОписаниеПути.ПутьКПрограмме = ПутиКМодулям;
			ОписаниеПути.Существует = Истина;
			Прервать;
		КонецЦикла;
		Если Не ОписаниеПути.Существует Тогда
			ОписаниеПути.ТекстОшибки = СтрСоединить(ТекстыОшибок, Символы.ПС);
		КонецЕсли;
		Прервать;
	КонецЦикла;
	
	Возврат ОписаниеПути;
	
КонецФункции

Функция ОдинИзМодулейСуществует(ПутиКМодулям, ТекстыОшибок)
	
	МодулиПрограммы = СтрРазделить(ПутиКМодулям, ":");
	Результат = Ложь;
	Для Каждого МодульПрограммы Из МодулиПрограммы Цикл
		Файл = Новый Файл(МодульПрограммы);
		Попытка
			Существует = Файл.Существует();
		Исключение
			Существует = Ложь;
			ИнформацияОбОшибке = ИнформацияОбОшибке();
			ТекстыОшибок.Добавить(КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
		КонецПопытки;
		Если Существует Тогда
			Результат = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ДоступнаПроверкаСертификатаВОблачномСервисеСПараметрами()
	
	Если Не ЭлектроннаяПодписьСлужебный.ИспользоватьЭлектроннуюПодписьВМоделиСервиса() Тогда
		Возврат Ложь;
	КонецЕсли;
	
	МодульТехнологияСервиса = ОбщегоНазначения.ОбщийМодуль("ТехнологияСервиса");
	Версия = МодульТехнологияСервиса.ВерсияБиблиотеки();
	
	Возврат ОбщегоНазначенияКлиентСервер.СравнитьВерсии(Версия, "2.0.3.0") > 0;
	
КонецФункции

#КонецОбласти
