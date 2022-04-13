﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.ВариантыОтчетов

// Настройки общей формы отчета подсистемы "Варианты отчетов".
//
// Параметры:
//   Форма - ФормаКлиентскогоПриложения, Неопределено - форма отчета или форма настроек отчета.
//       Неопределено когда вызов без контекста.
//   КлючВарианта - Строка, Неопределено - имя предопределенного
//       или уникальный идентификатор пользовательского варианта отчета.
//       Неопределено когда вызов без контекста.
//   Настройки - см. ОтчетыКлиентСервер.НастройкиОтчетаПоУмолчанию
//
Процедура ОпределитьНастройкиФормы(Форма, КлючВарианта, Настройки) Экспорт
	
	Настройки.ВыводитьСуммуВыделенныхЯчеек 						 = Ложь;
	Настройки.РазрешеноВыбиратьИНастраиватьВариантыБезСохранения = Истина;
	Настройки.СкрытьКомандыРассылки                              = Истина;
	Настройки.РазрешеноИзменятьСтруктуру						 = Ложь;
	Настройки.РазрешеноИзменятьВарианты							 = Ложь;
	Настройки.РазрешеноЗагружатьСхему 							 = Ложь;
	Настройки.РазрешеноРедактироватьСхему 						 = Ложь;
	Настройки.РазрешеноВосстанавливатьСтандартнуюСхему 			 = Истина;
	
	Настройки.События.ПриСозданииНаСервере = Истина;
	
	Настройки.ФормироватьСразу = Истина;
	
КонецПроцедуры

// См. ОтчетыПереопределяемый.ПриСозданииНаСервере.
Процедура ПриСозданииНаСервере(Форма, Отказ, СтандартнаяОбработка) Экспорт
	
	УчетнаяЗапись = Неопределено;
	
	Если Форма.Параметры.Свойство("УчетнаяЗапись") Тогда
		УчетнаяЗапись = Форма.Параметры.УчетнаяЗапись;
		УстановитьПараметрыДанных(КомпоновщикНастроек.Настройки, УчетнаяЗапись);
		Форма.КлючНазначенияИспользования = УчетнаяЗапись.Метаданные().ПолноеИмя();
	КонецЕсли;
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.ВариантыОтчетов

// Следующие процедуры и функции предназначены для интеграции с 1С-Отчетность

// Предназначена для формирования данных о состояние учетной записи облачной подписи.
//
// Параметры:
//  ДанныеРасшифровки	- Неопределено - возвращает данные о расшифровке
//  ДокументРезультат	- ТабличныйДокумент
//                   	- Неопределено
//
// Возвращаемое значение:
//  - ТабличныйДокумент 
//  - Строка
//
//
Функция СформироватьДанныеОтчета(ДанныеРасшифровки, ДокументРезультат = Неопределено) Экспорт
	
	Если ДокументРезультат = Неопределено Тогда
		ДокументРезультат	= Новый ТабличныйДокумент;
	КонецЕсли;
	
	НастройкиОтчета 	= КомпоновщикНастроек.ПолучитьНастройки();
	НастройкиПользователя = НастройкиОтчета.ПараметрыДанных.Элементы.Найти("НастройкиПользователя").Значение;
	ФорматРезультат 	= НастройкиОтчета.ПараметрыДанных.Элементы.Найти("ФорматРезультата").Значение;
	
	ДанныеОтчета 		= Отчеты.СостояниеУчетнойЗаписиDSS.СформироватьДанныеСостоянияУчетнойЗаписи(НастройкиПользователя);
	
	Если ФорматРезультат = "XML" Тогда
		ЗаписьДанных = Новый ЗаписьXML;
		ЗаписьДанных.УстановитьСтроку();
		ЗаписьДанных.ЗаписатьНачалоЭлемента("Начало");
		
		Для каждого СтрокаКлюча Из ДанныеОтчета.Таблицы Цикл
			ЗаписьДанных.ЗаписатьНачалоЭлемента(СтрокаКлюча.Ключ);
			СериализаторXDTO.ЗаписатьXML(ЗаписьДанных, СтрокаКлюча.Значение);
			ЗаписьДанных.ЗаписатьКонецЭлемента();
		КонецЦикла;	
		
		ЗаписьДанных.ЗаписатьКонецЭлемента();
		ДокументРезультат = ЗаписьДанных.Закрыть();
		
	Иначе
		КомпоновщикМакета 	= Новый КомпоновщикМакетаКомпоновкиДанных;
		МакетКомпоновки 	= КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, НастройкиОтчета, ДанныеРасшифровки);
		ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
		ПроцессорКомпоновки.Инициализировать(МакетКомпоновки, ДанныеОтчета.Таблицы, ДанныеРасшифровки, Истина);
		ПроцессорВывода 	= Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
		ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
		ПроцессорВывода.Вывести(ПроцессорКомпоновки);
		
	КонецЕсли;
	
	Возврат ДокументРезультат;
	
КонецФункции

#КонецОбласти

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	СтандартнаяОбработка= Ложь;
	СформироватьДанныеОтчета(ДанныеРасшифровки, ДокументРезультат);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура УстановитьПараметрыДанных(Настройки, УчетнаяЗапись, ПользовательскиеНастройки = Неопределено)
	
	НастройкиПользователя = СервисКриптографииDSSСлужебный.ПолучитьНастройкиПользователя(УчетнаяЗапись);
	ПараметрыДанных = Настройки.ПараметрыДанных;
	ПараметрыДанных.УстановитьЗначениеПараметра("НастройкиПользователя", НастройкиПользователя);
	
КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли
