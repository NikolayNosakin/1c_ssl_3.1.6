﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Или ДополнительныеСвойства.Свойство("НеПроверятьУникальность") Тогда
		Возврат;
	КонецЕсли;
	
	Если Предопределенный И Не ЭтоНовый() Тогда
		
		ПроверитьИзменениеПредопределенногоЭлемента();
		
	КонецЕсли;
	
	Если Не ПроверитьЗаполнение() Тогда
		Отказ = Истина;
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	СписокОшибок = ПроверитьУникальностьЭлементов();
	
	Если СписокОшибок.Количество() > 0 Тогда
		
		Отказ = Истина;
		Для каждого ОписаниеОшибки Из СписокОшибок Цикл
			ОбщегоНазначения.СообщитьПользователю(ОписаниеОшибки.ТекстСообщения,, ОписаниеОшибки.ИмяПоля);
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	Если ДанныеЗаполнения<>Неопределено Тогда
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, ДанныеЗаполнения);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Контролирует уникальность элемента в базе.
// В случае выявления дублей кодов или наименование возвращает их список.
//
//  Возвращаемое значение:
//      Массив из см. НовыйСообщениеОбОшибке - если в программе были найдены дубли, то содержит описание элементов
//        существующих в базе.
//
Функция ПроверитьУникальностьЭлементов()
	
	Результат = Новый Массив;
	
	// Нецифровые коды пропускаем
	ТипЧисло = Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(3, 0, ДопустимыйЗнак.Неотрицательный));
	Если Код= "0" Или Код = "00" Или Код = "000" Тогда
		КодПоиска = "000";
	Иначе
		КодПоиска = Формат(ТипЧисло.ПривестиЗначение(Код), "ЧЦ=3; ЧН=; ЧВН=");
	КонецЕсли;
		
	Запрос = Новый Запрос("
		|ВЫБРАТЬ ПЕРВЫЕ 10
		|	Код                КАК Код,
		|	Наименование       КАК Наименование,
		|	НаименованиеПолное КАК НаименованиеПолное,
		|	КодАльфа2          КАК КодАльфа2,
		|	КодАльфа3          КАК КодАльфа3,
		|	УчастникЕАЭС       КАК УчастникЕАЭС,
		|	Ссылка             КАК Ссылка
		|ИЗ
		|	Справочник.СтраныМира
		|ГДЕ
		|	(Код = &Код
		|	ИЛИ Наименование = &Наименование
		|	ИЛИ КодАльфа2 = &КодАльфа2
		|	ИЛИ КодАльфа3 = &КодАльфа3
		|	ИЛИ НаименованиеПолное = &НаименованиеПолное)
		|	И Ссылка <> &Ссылка
		|");
	Запрос.УстановитьПараметр("Ссылка",                Ссылка);
	Запрос.УстановитьПараметр("Код",                   КодПоиска);
	Запрос.УстановитьПараметр("Наименование",          Наименование);
	Запрос.УстановитьПараметр("НаименованиеПолное",    НаименованиеПолное);
	Запрос.УстановитьПараметр("КодАльфа2",             КодАльфа2);
	Запрос.УстановитьПараметр("КодАльфа3",             КодАльфа3);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Результат;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		
		Сообщение = НовыйСообщениеОбОшибке();
		Если СтрСравнить(Выборка.Код, Код) = 0 Тогда
			
			Сообщение.ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'С кодом %1 уже существует страна %2. Измените код или используйте уже существующие данные.'"),
				Код, Выборка.Наименование);
			Сообщение.ИмяПоля = "Объект.Код";
			
		ИначеЕсли СтрСравнить(Выборка.Наименование, Наименование) = 0 Тогда
			
			Сообщение.ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Страна с наименованием %1 уже существует. Измените наименование или используйте уже существующие данные.'"),
				Выборка.Наименование);
			Сообщение.ИмяПоля = "Объект.Наименование";
			
		ИначеЕсли ЗначениеЗаполнено(НаименованиеПолное)
				  И СтрСравнить(Выборка.НаименованиеПолное, НаименованиеПолное) = 0 Тогда
			
			Сообщение.ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Уже существует страна %2 с полным наименованием %1. Измените полное наименование или используйте уже существующие данные.'"),
				НаименованиеПолное, Выборка.Наименование);
			Сообщение.ИмяПоля = "Объект.НаименованиеПолное";
			
		ИначеЕсли ЗначениеЗаполнено(КодАльфа2)
				  И СтрСравнить(Выборка.КодАльфа2, КодАльфа2) = 0 Тогда
			
			Сообщение.ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'С кодом Альфа-2 %1 уже существует страна %2. Измените код Альфа-2 или используйте уже существующие данные.'"),
				КодАльфа2, Выборка.Наименование);
			Сообщение.ИмяПоля = "Объект.КодАльфа2";
			
		ИначеЕсли ЗначениеЗаполнено(КодАльфа3)
				  И СтрСравнить(Выборка.КодАльфа3, КодАльфа3) = 0 Тогда
			
			Сообщение.ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'С кодом Альфа-3 %1 уже существует страна %2. Измените код Альфа-3 или используйте уже существующие данные.'"),
				КодАльфа3, Выборка.Наименование);
			Сообщение.ИмяПоля = "Объект.КодАльфа3";
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Сообщение.ИмяПоля) Тогда
			Результат.Добавить(Сообщение);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Возвращаемое значение:
//  Структура:
//   ИмяПоля - Строка
//   ТекстСообщения - Строка
//
Функция НовыйСообщениеОбОшибке()
	
	Результат = Новый Структура;
	Результат.Вставить("ИмяПоля",        "");
	Результат.Вставить("ТекстСообщения", "");
	
	Возврат Результат;
	
КонецФункции

Процедура ПроверитьИзменениеПредопределенногоЭлемента()
	
	ПредыдущиеЗначения = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Ссылка, "Код, Наименование");
	Если СтрСравнить(ПредыдущиеЗначения.Наименование, Наименование) <> 0 Тогда
		
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не допускается изменение наименования для страны %1'"), ПредыдущиеЗначения.Наименование);
		ВызватьИсключение ТекстСообщения;
		
	КонецЕсли;
	
	Если СтрСравнить(ПредыдущиеЗначения.Код, Код) <> 0 Тогда
		
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не допускается изменение кода для страны %1'"), ПредыдущиеЗначения.Наименование);
		ВызватьИсключение ТекстСообщения;
		
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли