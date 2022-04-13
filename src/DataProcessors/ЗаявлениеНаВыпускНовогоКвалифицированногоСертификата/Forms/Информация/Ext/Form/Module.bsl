﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.ИнформацияЗаявления <> Неопределено Тогда
		ПодтверждаемаяИнформация = Параметры.ИнформацияЗаявления;
		Элементы.ГруппаОшибка.Видимость = Ложь;
		Элементы.ГруппаЗаявление.Видимость = Истина;
		Элементы.ГруппаСертификат.Видимость = Ложь;
	ИначеЕсли Параметры.СодержаниеСертификата <> Неопределено Тогда
		Элементы.ГруппаЗаявление.Видимость = Ложь;
		Элементы.ГруппаСертификат.Видимость = Истина;
	Иначе
		Заголовок = НСтр("ru = 'Информация об ошибке'");
		Элементы.ГруппаКомандыОшибки.Видимость = Истина;
		Элементы.ГруппаКомандыПодтверждения.Видимость = Ложь; 	
		Элементы.ГруппаЗаявление.Видимость = Ложь;
		Элементы.ГруппаСертификат.Видимость = Ложь;
	КонецЕсли;	
	
	Если Параметры.ОписаниеОшибки <> Неопределено Тогда
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, Параметры.ОписаниеОшибки);
		Элементы.ГруппаОшибка.Видимость = ЗначениеЗаполнено(Описание);
		Элементы.ГруппаТекстОшибки.Видимость = ЗначениеЗаполнено(Текст);
		Если ЗначениеЗаполнено(Код) Тогда
			ОписаниеИзвестнойОшибки = ЭлектроннаяПодписьСлужебный.ОшибкаПоКлассификатору(Код);
			ЭтоИзвестнаяОшибка = ОписаниеИзвестнойОшибки <> Неопределено;
			Если ЭтоИзвестнаяОшибка Тогда
				ЗаполнитьЗначенияСвойств(ЭтотОбъект, ОписаниеИзвестнойОшибки);
				Элементы.Причина.Видимость = ЗначениеЗаполнено(Причина);
				Элементы.Решение.Видимость = ЗначениеЗаполнено(Решение);
				Элементы.СпособУстранения.Видимость = ЗначениеЗаполнено(СпособУстранения);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	ЭлектроннаяПодписьСлужебный.СброситьРазмерыИПоложениеОкна(ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы	

&НаКлиенте
Процедура Подтверждаю(Команда)
	
	Если Не СогласиеСПодтверждаемойИнформацией Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(
			НСтр("ru = 'Поставьте отметку о подтверждении'"),, "СогласиеСПодтверждаемойИнформацией");
		Возврат;
	КонецЕсли;	
	Закрыть(Истина);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ДекорацияИнструкцияОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	
	ИдентификаторПечатнойФормы = "СодержаниеСертификата";
	НазваниеПечатнойФормы = НСтр("ru = 'Содержание сертификата'");
	
	Если Не ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.Печать") Тогда
		Параметры.СодержаниеСертификата.Показать(НазваниеПечатнойФормы);
		Возврат;
	КонецЕсли;
	
	МодульУправлениеПечатьюКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("УправлениеПечатьюКлиент");
	КоллекцияПечатныхФорм = МодульУправлениеПечатьюКлиент.НоваяКоллекцияПечатныхФорм(ИдентификаторПечатнойФормы);
	
	ПечатнаяФорма = МодульУправлениеПечатьюКлиент.ОписаниеПечатнойФормы(КоллекцияПечатныхФорм, ИдентификаторПечатнойФормы);
	ПечатнаяФорма.СинонимМакета = НазваниеПечатнойФормы;
	ПечатнаяФорма.ТабличныйДокумент = Параметры.СодержаниеСертификата;
	ПечатнаяФорма.ИмяФайлаПечатнойФормы = НазваниеПечатнойФормы;
	
	ОбластиОбъектов = Новый СписокЗначений;
	МодульУправлениеПечатьюКлиент.ПечатьДокументов(КоллекцияПечатныхФорм, ОбластиОбъектов);
	
КонецПроцедуры


#КонецОбласти