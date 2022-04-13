﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем ОбновитьИнтерфейс;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЭтоАдминистраторСистемы   = Пользователи.ЭтоПолноправныйПользователь(, Истина);
	РазделениеВключено        = ОбщегоНазначения.РазделениеВключено();
	ЭтоАвтономноеРабочееМесто = ОбщегоНазначения.ЭтоАвтономноеРабочееМесто();
	
	Элементы.ГруппаКлассификаторы.Видимость = Не РазделениеВключено;
	
	Если Элементы.ГруппаКлассификаторы.Видимость Тогда
		
		Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.АдресныйКлассификатор") Тогда
			МодульАдресныйКлассификаторСлужебный = ОбщегоНазначения.ОбщийМодуль("АдресныйКлассификаторСлужебный");
			Если Не МодульАдресныйКлассификаторСлужебный.ЕстьПравоДобавлениеИзменениеАдресныхСведений() Тогда
				Элементы.АдресныйКлассификаторНастройки.Видимость = Ложь;
			КонецЕсли;
		Иначе
			Элементы.АдресныйКлассификаторНастройки.Видимость = Ложь;
		КонецЕсли;
		
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Валюты") Тогда
		Элементы.ГруппаОбработкаЗагрузкаКурсовВалют.Видимость =
			  Не РазделениеВключено
			И Не ЭтоАвтономноеРабочееМесто;
	Иначе
		Элементы.ГруппаОбработкаЗагрузкаКурсовВалют.Видимость = Ложь;
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.СклонениеПредставленийОбъектов") Тогда
		Элементы.ГруппаСклонения.Видимость =
			  Не РазделениеВключено
			И Не ЭтоАвтономноеРабочееМесто
			И ЭтоАдминистраторСистемы;
	Иначе
		Элементы.ГруппаСклонения.Видимость = Ложь;
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ВызовОнлайнПоддержки") Тогда
		Элементы.ГруппаИнтеграцияВызовОнлайнПоддержки.Видимость =
			ОбщегоНазначения.ЭтоWindowsКлиент();
	Иначе
		Элементы.ГруппаИнтеграцияВызовОнлайнПоддержки.Видимость = Ложь;
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ЦентрМониторинга") Тогда
		Элементы.ГруппаЦентрМониторинга.Видимость = ЭтоАдминистраторСистемы;
		Если ЭтоАдминистраторСистемы Тогда
			ПараметрыЦентраМониторинга = ПолучитьПараметрыЦентраМониторинга();
			ЦентрМониторингаРазрешитьОтправлятьДанные = ПолучитьПереключательОтправкиДанных(ПараметрыЦентраМониторинга.ВключитьЦентрМониторинга, ПараметрыЦентраМониторинга.ЦентрОбработкиИнформацииОПрограмме);
			
			ПараметрыСервиса = Новый Структура("Сервер, АдресРесурса, Порт");
			Если ЦентрМониторингаРазрешитьОтправлятьДанные = 0 Тогда
				ПараметрыСервиса.Сервер = ПараметрыЦентраМониторинга.СерверПоУмолчанию;
				ПараметрыСервиса.АдресРесурса = ПараметрыЦентраМониторинга.АдресРесурсаПоУмолчанию;
				ПараметрыСервиса.Порт = ПараметрыЦентраМониторинга.ПортПоУмолчанию;
			ИначеЕсли ЦентрМониторингаРазрешитьОтправлятьДанные = 1 Тогда
				ПараметрыСервиса.Сервер = ПараметрыЦентраМониторинга.Сервер;
				ПараметрыСервиса.АдресРесурса = ПараметрыЦентраМониторинга.АдресРесурса;
				ПараметрыСервиса.Порт = ПараметрыЦентраМониторинга.Порт;
			ИначеЕсли ЦентрМониторингаРазрешитьОтправлятьДанные = 2 Тогда
				ПараметрыСервиса = Неопределено;
			КонецЕсли;
			
			Если ПараметрыСервиса <> Неопределено Тогда
				Если ПараметрыСервиса.Порт = 80 Тогда
					Схема = "http://";
					Порт = "";
				ИначеЕсли ПараметрыСервиса.Порт = 443 Тогда
					Схема = "https://";
					Порт = "";
				Иначе
					Схема = "http://";
					Порт = ":" + Формат(ПараметрыСервиса.Порт, "ЧН=0; ЧГ=");
				КонецЕсли;
				
				ЦентрМониторингаАдресСервиса = Схема + ПараметрыСервиса.Сервер + Порт + "/" + ПараметрыСервиса.АдресРесурса;
			Иначе
				ЦентрМониторингаАдресСервиса = "";
			КонецЕсли;
			
			Элементы.ЦентрМониторингаАдресСервиса.Доступность = (ЦентрМониторингаРазрешитьОтправлятьДанные = 1);
			Элементы.ЦентрМониторингаНастройки.Доступность = (ЦентрМониторингаРазрешитьОтправлятьДанные <> 2);
			Элементы.ГруппаОтправитьКонтактнуюИнформацию.Видимость = ПараметрыЦентраМониторинга.ЗапросКонтактнойИнформации <> 2;
		КонецЕсли;
	Иначе
		Элементы.ГруппаЦентрМониторинга.Видимость = Ложь;
	КонецЕсли;
	
	ВидимостьГруппыВнешниеКомпоненты = Ложь;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ВнешниеКомпоненты") Тогда 
		
		МодульВнешниеКомпонентыСлужебный = ОбщегоНазначения.ОбщийМодуль("ВнешниеКомпонентыСлужебный");
		ВидимостьГруппыВнешниеКомпоненты = МодульВнешниеКомпонентыСлужебный.ДоступнаЗагрузкаСПортала();
		
	КонецЕсли;
	
	Элементы.ГруппаВнешниеКомпоненты.Видимость = ВидимостьГруппыВнешниеКомпоненты;
	
	// Обновление состояния элементов.
	УстановитьДоступность();
	
	ОбрабатыватьНастройкиБИП = ОбщегоНазначения.ПодсистемаСуществует("ИнтернетПоддержкаПользователей");
	
	Если ОбрабатыватьНастройкиБИП Тогда
		МодульИнтеграцияПодсистемБИП = ОбщегоНазначения.ОбщийМодуль("ИнтеграцияПодсистемБИП");
		МодульИнтеграцияПодсистемБИП.ИнтернетПоддержкаИСервисы_ПриСозданииНаСервере(ЭтотОбъект);
	Иначе
		Элементы.БИПГруппаНастройки.Видимость                      = Ложь;
		Элементы.БИПГруппаНовости.Видимость                        = Ложь;
		Элементы.БИПГруппаОбновлениеПрограммы.Видимость            = Ложь;
		Элементы.БИПГруппаОбновлениеКлассификаторов.Видимость      = Ложь;
		Элементы.БИПГруппаПроверкаКонтрагентов.Видимость           = Ложь;
		Элементы.БИПГруппаСПАРКРиски.Видимость                     = Ложь;
		Элементы.БИПГруппаИнтеграцияСКоннект.Видимость             = Ложь;
		Элементы.БИПГруппаИнтеграцияСПлатежнымиСистемами.Видимость = Ложь;
	КонецЕсли;
	
	// Дополнительная проверка необходимо, т.к. программа может содержать версию БИП
	// ниже чем 2.4.1.51. Проверка будет удалена при переходе на новую редакцию БСП.
	Если Не ОбщегоНазначения.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ИнтеграцияСКоннект") Тогда
		Элементы.БИПГруппаИнтеграцияСКоннект.Видимость = Ложь;
	КонецЕсли;
	
	// Дополнительная проверка необходимо, т.к. программа может содержать версию БИП
	// ниже чем 2.6.1.25. Проверка будет удалена при переходе на новую редакцию БСП.
	Если ОбщегоНазначения.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ИнтеграцияСПлатежнымиСистемами") Тогда
		МодульИнтернетПоддержкаПользователейКлиентСервер = ОбщегоНазначения.ОбщийМодуль("ИнтернетПоддержкаПользователейКлиентСервер");
		Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(
			МодульИнтернетПоддержкаПользователейКлиентСервер.ВерсияБиблиотеки(), "2.6.1.25") < 0 Тогда
		Элементы.БИПДлительностьОперацииПлатежнойСистемы.Видимость = Ложь;
		КонецЕсли;
	КонецЕсли;
	
	НастройкиПрограммыПереопределяемый.ИнтернетПоддержкаИСервисыПриСозданииНаСервере(ЭтотОбъект);
	
	Элементы.ГруппаОбсуждения.Видимость = ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Обсуждения");
	
	СистемнаяИнформация = Новый СистемнаяИнформация();
	ВерсияПлатформы = СистемнаяИнформация.ВерсияПриложения;

	Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии("8.3.17.0", ВерсияПлатформы) > 0 Тогда
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы,
			"ОбсужденияНастроитьИнтеграциюСВнешнимиСистемами",
			"Видимость",
			Ложь);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ПриИзмененииСостоянияПодключенияОбсуждений();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ИнтернетПоддержкаОтключена" Или ИмяСобытия = "ИнтернетПоддержкаПодключена" Тогда
		ОбновитьПовторноИспользуемыеЗначения();
	КонецЕсли;
	
	Если ИмяСобытия = "СкрытиеКонфиденциальнойИнформации" И ОбрабатыватьНастройкиБИП Тогда
		ОбновитьСостояниеИнтернетПоддержки();
	КонецЕсли;
	
	Если ОбрабатыватьНастройкиБИП Тогда
		Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.БазоваяФункциональностьБИП") Тогда
			МодульИнтеграцияПодсистемБИПКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ИнтеграцияПодсистемБИПКлиент");
			МодульИнтеграцияПодсистемБИПКлиент.ИнтернетПоддержкаИСервисы_ОбработкаОповещения(
				ЭтотОбъект,
				ИмяСобытия,
				Параметр,
				Источник);
		КонецЕсли;
	КонецЕсли;
	
	Если ИмяСобытия = "ОбсужденияПодключены" Тогда 
		ПриИзмененииСостоянияПодключенияОбсуждений(Параметр);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	Если ЗавершениеРаботы Тогда
		Возврат;
	КонецЕсли;
	ОбновитьИнтерфейсПрограммы();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура РазрешитьОтправлятьДанныеПриИзменении(Элемент)
	Перем РезультатЗапуска;
	Элементы.ЦентрМониторингаАдресСервиса.Доступность = (ЦентрМониторингаРазрешитьОтправлятьДанные = 1);
	Элементы.ЦентрМониторингаНастройки.Доступность = (ЦентрМониторингаРазрешитьОтправлятьДанные <> 2);
	Если ЦентрМониторингаРазрешитьОтправлятьДанные = 2 Тогда
		ПараметрыЦентраМониторингаЗапись = Новый Структура("ВключитьЦентрМониторинга, ЦентрОбработкиИнформацииОПрограмме", Ложь, Ложь);
	ИначеЕсли ЦентрМониторингаРазрешитьОтправлятьДанные = 1 Тогда
		ПараметрыЦентраМониторингаЗапись = Новый Структура("ВключитьЦентрМониторинга, ЦентрОбработкиИнформацииОПрограмме", Ложь, Истина);
	ИначеЕсли ЦентрМониторингаРазрешитьОтправлятьДанные = 0 Тогда
		ПараметрыЦентраМониторингаЗапись = Новый Структура("ВключитьЦентрМониторинга, ЦентрОбработкиИнформацииОПрограмме", Истина, Ложь);
	КонецЕсли;
	ЦентрМониторингаАдресСервиса = ПолучитьАдресСервиса();
	РазрешитьОтправлятьДанныеПриИзмененииНаСервере(ПараметрыЦентраМониторингаЗапись, РезультатЗапуска);
	Если РезультатЗапуска <> Неопределено Тогда
		ЦентрМониторингаИдентификаторЗадания = РезультатЗапуска.ИдентификаторЗадания;
		ЦентрМониторингаАдресРезультатаЗадания = РезультатЗапуска.АдресРезультата;
		МодульЦентрМониторингаКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ЦентрМониторингаКлиент");
		Оповещение = Новый ОписаниеОповещения("ПослеОбновленияИдентификатора", МодульЦентрМониторингаКлиент);
		ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
		ПараметрыОжидания.ВыводитьОкноОжидания = Ложь;
		ДлительныеОперацииКлиент.ОжидатьЗавершение(РезультатЗапуска, Оповещение, ПараметрыОжидания); 
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЦентрМониторингаАдресСервисаПриИзменении(Элемент)
	Попытка
		СтруктураАдреса = ОбщегоНазначенияКлиентСервер.СтруктураURI(ЦентрМониторингаАдресСервиса);
		
		Если СтруктураАдреса.Схема = "http" Тогда
			СтруктураАдреса.Вставить("ЗащищенноеСоединение", Ложь);
		ИначеЕсли СтруктураАдреса.Схема = "https" Тогда
			СтруктураАдреса.Вставить("ЗащищенноеСоединение", Истина);
        Иначе
            СтруктураАдреса.Вставить("ЗащищенноеСоединение", Ложь);
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(СтруктураАдреса.Порт) Тогда
			Если СтруктураАдреса.Схема = "http" Тогда
				СтруктураАдреса.Порт = 80;
			ИначеЕсли СтруктураАдреса.Схема = "https" Тогда
				СтруктураАдреса.Порт = 443;
            Иначе
                СтруктураАдреса.Порт = 80;
			КонецЕсли;
		КонецЕсли;
	Исключение
		// Внимание, формат адреса должен соответствовать RFC 3986 
		// см. описание функции ОбщегоНазначенияКлиентСервер.СтруктураURI.
		ОписаниеОшибки = НСтр("ru = 'Адрес сервиса'") + " "
			+ ЦентрМониторингаАдресСервиса + " "
			+ НСтр("ru = 'не является допустимым адресом веб-сервиса для отправки отчетов об использовании программы.'"); 
		ВызватьИсключение(ОписаниеОшибки);
	КонецПопытки;
	
	ЦентрМониторингаАдресСервисаПриИзмененииНаСервере(СтруктураАдреса);
КонецПроцедуры

&НаКлиенте
Процедура ИнтеграцияВызовОнлайнПоддержкиПриИзменении(Элемент)
	Подключаемый_ПриИзмененииРеквизита(Элемент);
КонецПроцедуры

#Область ИнтернетПоддержкаПользователейОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ДекорацияЛогинИППОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	
	МодульИнтеграцияПодсистемБИПКлиент =
		ОбщегоНазначенияКлиент.ОбщийМодуль("ИнтеграцияПодсистемБИПКлиент");
	МодульИнтеграцияПодсистемБИПКлиент.ИнтернетПоддержкаИСервисы_ДекорацияОбработкаНавигационнойСсылки(
		ЭтотОбъект,
		Элемент,
		НавигационнаяСсылкаФорматированнойСтроки,
		СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура АвтоматическаяПроверкаОбновленийПриИзменении(Элемент)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ПолучениеОбновленийПрограммы") Тогда
		МодульПолучениеОбновленийПрограммыКлиент =
			ОбщегоНазначенияКлиент.ОбщийМодуль("ПолучениеОбновленийПрограммыКлиент");
		МодульПолучениеОбновленийПрограммыКлиент.ИнтернетПоддержкаИСервисы_АвтоматическаяПроверкаОбновленийПриИзменении(
			ЭтотОбъект,
			Элемент);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДекорацияРасписаниеПроверкиОбновленийНажатие(Элемент)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ПолучениеОбновленийПрограммы") Тогда
		МодульПолучениеОбновленийПрограммыКлиент =
			ОбщегоНазначенияКлиент.ОбщийМодуль("ПолучениеОбновленийПрограммыКлиент");
		МодульПолучениеОбновленийПрограммыКлиент.ИнтернетПоддержкаИСервисы_ДекорацияРасписаниеПроверкиОбновленийНажатие(
			ЭтотОбъект,
			Элемент);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура КаталогДистрибутиваПлатформыНажатие(Элемент, СтандартнаяОбработка)
	
	МодульПолучениеОбновленийПрограммыКлиент =
		ОбщегоНазначенияКлиент.ОбщийМодуль("ПолучениеОбновленийПрограммыКлиент");
	МодульПолучениеОбновленийПрограммыКлиент.ИнтернетПоддержкаИСервисы_КаталогДистрибутиваПлатформыНажатие(
		ЭтотОбъект,
		Элемент,
		СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура ДетализироватьОбновлениеИБВЖурналеРегистрацииПриИзменении(Элемент)
	Подключаемый_ПриИзмененииРеквизита(Элемент);
КонецПроцедуры

&НаКлиенте
Процедура ДекорацияРасписаниеУстановкаИсправленийНажатие(Элемент)
	
	МодульПолучениеОбновленийПрограммыКлиент =
		ОбщегоНазначенияКлиент.ОбщийМодуль("ПолучениеОбновленийПрограммыКлиент");
	МодульПолучениеОбновленийПрограммыКлиент.ИнтернетПоддержкаИСервисы_ДекорацияРасписаниеУстановкаИсправленийНажатие(
		ЭтотОбъект,
		Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура БИПВключитьРаботуСНовостямиПриИзменении(Элемент)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.Новости") Тогда
		МодульОбработкаНовостейКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОбработкаНовостейКлиент");
		МодульОбработкаНовостейКлиент.ИнтернетПоддержкаИСервисы_ВключитьРаботуСНовостямиПриИзменении(
			ЭтотОбъект,
			Элемент);
		ОбновитьИнтерфейс = Истина;
		ПодключитьОбработчикОжидания("ОбновитьИнтерфейсПрограммы", 2, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура БИПИспользоватьСервисСПАРКРискиПриИзменении(Элемент)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.СПАРКРиски") Тогда
		МодульСПАРКРискиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("СПАРКРискиКлиент");
		МодульСПАРКРискиКлиент.ИнтернетПоддержкаИСервисы_ИспользоватьСервисСПАРКРискиПриИзменении(
			ЭтотОбъект,
			Элемент);
		ОбновитьИнтерфейс = Истина;
		ПодключитьОбработчикОжидания("ОбновитьИнтерфейсПрограммы", 2, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура БИПЗагружатьИУстанавливатьИсправленияАвтоматическиПриИзменении(Элемент)
	
	МодульПолучениеОбновленийПрограммыКлиент =
		ОбщегоНазначенияКлиент.ОбщийМодуль("ПолучениеОбновленийПрограммыКлиент");
	МодульПолучениеОбновленийПрограммыКлиент.ИнтернетПоддержкаИСервисы_ЗагружатьИУстанавливатьИсправленияАвтоматическиПриИзменении(
		ЭтотОбъект,
		Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура БИПФайлКлассификаторовНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.РаботаСКлассификаторами") Тогда
		МодульРаботаСКлассификаторамиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("РаботаСКлассификаторамиКлиент");
		МодульРаботаСКлассификаторамиКлиент.ИнтернетПоддержкаИСервисы_БИПФайлКлассификаторовНачалоВыбора(
			ЭтотОбъект,
			Элемент,
			ДанныеВыбора,
			СтандартнаяОбработка);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура БИПВариантОбновленияКлассификаторовПриИзменении(Элемент)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.РаботаСКлассификаторами") Тогда
		МодульРаботаСКлассификаторамиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("РаботаСКлассификаторамиКлиент");
		МодульРаботаСКлассификаторамиКлиент.ИнтернетПоддержкаИСервисы_БИПВариантОбновленияКлассификаторовПриИзменении(
			ЭтотОбъект,
			Элемент);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДекорацияРасписаниеОбновленияКлассификаторовНажатие(Элемент)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.РаботаСКлассификаторами") Тогда
		МодульРаботаСКлассификаторамиКлиент =
			ОбщегоНазначенияКлиент.ОбщийМодуль("РаботаСКлассификаторамиКлиент");
		МодульРаботаСКлассификаторамиКлиент.ИнтернетПоддержкаИСервисы_ДекорацияРасписаниеОбновленияКлассификаторовНажатие(
			ЭтотОбъект,
			Элемент);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура БИПИнтеграцияСКоннектПриИзменении(Элемент)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ИнтеграцияСКоннект") Тогда
		МодульИнтеграцияСКоннектКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ИнтеграцияСКоннектКлиент");
		МодульИнтеграцияСКоннектКлиент.ИнтернетПоддержкаИСервисы_БИПИнтеграцияСКоннектПриИзменении(
			ЭтотОбъект,
			Элемент);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура БИПДлительностьОперацииПлатежнойСистемыПриИзменении(Элемент)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ИнтеграцияСПлатежнымиСистемами") Тогда
		МодульИнтеграцияСПлатежнымиСистемамиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ИнтеграцияСПлатежнымиСистемамиКлиент");
		МодульИнтеграцияСПлатежнымиСистемамиКлиент.БИПДлительностьОперацииПлатежнойСистемыПриИзменении(
			ЭтотОбъект,
			Элемент);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область ОбработчикиКомандФормы

// СтандартныеПодсистемы.ОбновлениеВерсииИБ
&НаКлиенте
Процедура ОтложеннаяОбработкаДанных(Команда)
	
	ПараметрыФормы = Новый Структура("ОткрытиеИзПанелиАдминистрирования", Истина);
	ОткрытьФорму(
		"Обработка.РезультатыОбновленияПрограммы.Форма.РезультатыОбновленияПрограммы",
		ПараметрыФормы);
	
КонецПроцедуры
// Конец СтандартныеПодсистемы.ОбновлениеВерсииИБ

#Область ИнтернетПоддержкаПользователейОбработчикиКомандФормы

&НаКлиенте
Процедура БИПВойтиИлиВыйти(Команда)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.БазоваяФункциональностьБИП") Тогда
		МодульИнтеграцияПодсистемБИПКлиент =
			ОбщегоНазначенияКлиент.ОбщийМодуль("ИнтеграцияПодсистемБИПКлиент");
		МодульИнтеграцияПодсистемБИПКлиент.ИнтернетПоддержкаИСервисы_БИПВойтиИлиВыйти(
			ЭтотОбъект,
			Команда);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура БИПСообщениеВСлужбуТехническойПоддержки(Команда)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.БазоваяФункциональностьБИП") Тогда
		МодульИнтеграцияПодсистемБИПКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ИнтеграцияПодсистемБИПКлиент");
		МодульИнтеграцияПодсистемБИПКлиент.ИнтернетПоддержкаИСервисы_СообщениеВСлужбуТехническойПоддержки(
			ЭтотОбъект,
			Команда);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура БИПМониторИнтернетПоддержки(Команда)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.МониторПортала1СИТС") Тогда
		МодульМониторПортала1СИТСКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("МониторПортала1СИТСКлиент");
		МодульМониторПортала1СИТСКлиент.ИнтернетПоддержкаИСервисы_МониторПортала1СИТС(
			ЭтотОбъект,
			Команда);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура БИПУправлениеНовостями(Команда)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.Новости") Тогда
		МодульОбработкаНовостейКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОбработкаНовостейКлиент");
		МодульОбработкаНовостейКлиент.ИнтернетПоддержкаИСервисы_УправлениеНовостями(
			ЭтотОбъект,
			Команда);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура БИПОбновлениеПрограммы(Команда)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ПолучениеОбновленийПрограммы") Тогда
		МодульПолучениеОбновленийПрограммыКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ПолучениеОбновленийПрограммыКлиент");
		МодульПолучениеОбновленийПрограммыКлиент.ИнтернетПоддержкаИСервисы_ОбновлениеПрограммы(
			ЭтотОбъект,
			Команда);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура БИПОбновлениеКлассификаторов(Команда)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.РаботаСКлассификаторами") Тогда
		МодульРаботаСКлассификаторамиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("РаботаСКлассификаторамиКлиент");
		МодульРаботаСКлассификаторамиКлиент.ИнтернетПоддержкаИСервисы_ОбновлениеКлассификаторов(
			ЭтотОбъект,
			Команда);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура БИПФайлКлассификаторовПриИзменении(Элемент)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.РаботаСКлассификаторами") Тогда
		МодульРаботаСКлассификаторамиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("РаботаСКлассификаторамиКлиент");
		МодульРаботаСКлассификаторамиКлиент.ИнтернетПоддержкаИСервисы_БИПФайлКлассификаторовПриИзменении(
			ЭтотОбъект,
			Элемент);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура БИПДекорацияОбновлениеКлассификаторовНеВыполняетсяОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.РаботаСКлассификаторами") Тогда
		МодульРаботаСКлассификаторамиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("РаботаСКлассификаторамиКлиент");
		МодульРаботаСКлассификаторамиКлиент.ИнтернетПоддержкаИСервисы_БИПДекорацияОбновлениеКлассификаторовНеВыполняетсяОбработкаНавигационнойСсылки(
			ЭтотОбъект,
			Элемент,
			НавигационнаяСсылкаФорматированнойСтроки,
			СтандартнаяОбработка);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура БИПИспользоватьПроверкуКонтрагентовПриИзменении(Элемент)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.РаботаСКонтрагентами") Тогда
		МодульРаботаСКонтрагентамиКлиент =
			ОбщегоНазначенияКлиент.ОбщийМодуль("РаботаСКонтрагентамиКлиент");
		МодульРаботаСКонтрагентамиКлиент.ИнтернетПоддержкаИСервисы_ИспользоватьПроверкуКонтрагентовПриИзменении(
			ЭтотОбъект,
			Элемент);
		ОбновитьИнтерфейс = Истина;
		ПодключитьОбработчикОжидания("ОбновитьИнтерфейсПрограммы", 2, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура БИППроверкаКонтрагентовПроверитьДоступКВебСервису(Команда)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.РаботаСКонтрагентами") Тогда
		МодульРаботаСКонтрагентамиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("РаботаСКонтрагентамиКлиент");
		МодульРаботаСКонтрагентамиКлиент.ИнтернетПоддержкаИСервисы_БИППроверкаКонтрагентовПроверитьДоступКВебСервису(
			ЭтотОбъект,
			Команда);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура БИПНастройкаИнтеграцииСПлатежнымиСистемами(Команда)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ИнтеграцияСПлатежнымиСистемами") Тогда
		МодульИнтеграцияСПлатежнымиСистемамиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ИнтеграцияСПлатежнымиСистемамиКлиент");
		МодульИнтеграцияСПлатежнымиСистемамиКлиент.ИнтернетПоддержкаИСервисы_БИПНастройкаИнтеграцииСПлатежнымиСистемами(
			ЭтотОбъект,
			Команда);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура БИПНастройкаИнтеграцииСКоннект(Команда)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ИнтеграцияСКоннект") Тогда
		МодульИнтеграцияСКоннектКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ИнтеграцияСКоннектКлиент");
		МодульИнтеграцияСКоннектКлиент.ИнтернетПоддержкаИСервисы_БИПНастройкаИнтеграцииСКоннект(
			ЭтотОбъект,
			Команда);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

&НаКлиенте
Процедура ПодключитьОтключитьОбсуждения(Команда)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.Обсуждения") Тогда
		
		МодульОбсужденияСлужебныйКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОбсужденияСлужебныйКлиент");
		
		Если МодульОбсужденияСлужебныйКлиент.Подключены() Тогда
			МодульОбсужденияСлужебныйКлиент.ПоказатьОтключение();
		Иначе 
			МодульОбсужденияСлужебныйКлиент.ПоказатьПодключение();
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура НастройкаОнлайнПоддержки(Команда)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ВызовОнлайнПоддержки") Тогда
		МодульВызовОнлайнПоддержкиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ВызовОнлайнПоддержкиКлиент");
		МодульВызовОнлайнПоддержкиКлиент.ОткрытьФормуНастройкаОнлайнПоддержки();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область СлужебныеОбработчикиСобытий

&НаКлиенте
Процедура ПриИзмененииСостоянияПодключенияОбсуждений(ОбсужденияПодключены = Неопределено)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.Обсуждения") Тогда
		
		Если ОбсужденияПодключены = Неопределено Тогда 
			МодульОбсужденияСлужебныйКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОбсужденияСлужебныйКлиент");
			ОбсужденияПодключены = МодульОбсужденияСлужебныйКлиент.Подключены();
		КонецЕсли;
		
		Если ОбсужденияПодключены Тогда 
			Элементы.ПодключитьОтключитьОбсуждения.Заголовок = НСтр("ru = 'Отключить'");
			Элементы.СостояниеПодключенияОбсуждений.Заголовок = НСтр("ru = 'Обсуждения подключены.'");
			ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, 
				"ОбсужденияНастроитьИнтеграциюСВнешнимиСистемами",
				"Доступность",
				Истина);
		Иначе 
			Элементы.ПодключитьОтключитьОбсуждения.Заголовок = НСтр("ru = 'Подключить'");
			Элементы.СостояниеПодключенияОбсуждений.Заголовок = НСтр("ru = 'Подключение обсуждений не выполнено.'");
			ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, 
				"ОбсужденияНастроитьИнтеграциюСВнешнимиСистемами",
				"Доступность",
				Ложь);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

////////////////////////////////////////////////////////////////////////////////
// Клиент

&НаКлиенте
Процедура Подключаемый_ПриИзмененииРеквизита(Элемент, НеобходимоОбновлятьИнтерфейс = Истина)
	
	ИмяКонстанты = ПриИзмененииРеквизитаСервер(Элемент.Имя);
	ОбновитьПовторноИспользуемыеЗначения();
	
	Если НеобходимоОбновлятьИнтерфейс Тогда
		ОбновитьИнтерфейс = Истина;
		ПодключитьОбработчикОжидания("ОбновитьИнтерфейсПрограммы", 2, Истина);
	КонецЕсли;
	
	Если ИмяКонстанты <> "" Тогда
		Оповестить("Запись_НаборКонстант", Новый Структура, ИмяКонстанты);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьИнтерфейсПрограммы()
	
	Если ОбновитьИнтерфейс = Истина Тогда
		ОбновитьИнтерфейс = Ложь;
		ОбщегоНазначенияКлиент.ОбновитьИнтерфейсПрограммы();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьАдресСервиса()
	
	ПараметрыЦентраМониторинга = ПолучитьПараметрыЦентраМониторинга();
			
	ПараметрыСервиса = Новый Структура("Сервер, АдресРесурса, Порт");
	
	Если ЦентрМониторингаРазрешитьОтправлятьДанные = 0 Тогда
		ПараметрыСервиса.Сервер = ПараметрыЦентраМониторинга.СерверПоУмолчанию;
		ПараметрыСервиса.АдресРесурса = ПараметрыЦентраМониторинга.АдресРесурсаПоУмолчанию;
		ПараметрыСервиса.Порт = ПараметрыЦентраМониторинга.ПортПоУмолчанию;
	ИначеЕсли ЦентрМониторингаРазрешитьОтправлятьДанные = 1 Тогда
		ПараметрыСервиса.Сервер = ПараметрыЦентраМониторинга.Сервер;
		ПараметрыСервиса.АдресРесурса = ПараметрыЦентраМониторинга.АдресРесурса;
		ПараметрыСервиса.Порт = ПараметрыЦентраМониторинга.Порт;
	ИначеЕсли ЦентрМониторингаРазрешитьОтправлятьДанные = 2 Тогда
		ПараметрыСервиса = Неопределено;	
	КонецЕсли;
	
	Если ПараметрыСервиса <> Неопределено Тогда
		Если ПараметрыСервиса.Порт = 80 Тогда
			Схема = "http://";
			Порт = "";
		ИначеЕсли ПараметрыСервиса.Порт = 443 Тогда
			Схема = "https://";
			Порт = "";
		Иначе
			Схема = "http://";
			Порт = ":" + Формат(ПараметрыСервиса.Порт, "ЧН=0; ЧГ=");
		КонецЕсли;
		
		АдресСервиса = Схема + ПараметрыСервиса.Сервер + Порт + "/" + ПараметрыСервиса.АдресРесурса;
	Иначе
		АдресСервиса = "";
	КонецЕсли;
	
	Возврат АдресСервиса;
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Вызов сервера

&НаСервере
Функция ПриИзмененииРеквизитаСервер(ИмяЭлемента)
	
	РеквизитПутьКДанным = Элементы[ИмяЭлемента].ПутьКДанным;
	ИмяКонстанты = СохранитьЗначениеРеквизита(РеквизитПутьКДанным);
	УстановитьДоступность(РеквизитПутьКДанным);
	
	Если ИмяЭлемента = "ИспользоватьСервисСклоненияMorpher"
		И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.СклонениеПредставленийОбъектов") Тогда
		МодульСклонениеПредставленийОбъектов = ОбщегоНазначения.ОбщийМодуль("СклонениеПредставленийОбъектов");
		МодульСклонениеПредставленийОбъектов.УстановитьДоступностьСервисаСклонения(Истина);
	КонецЕсли;
	
	ОбновитьПовторноИспользуемыеЗначения();
	Возврат ИмяКонстанты;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Сервер

&НаСервере
Процедура ОбновитьСостояниеИнтернетПоддержки()
	МодульИнтеграцияПодсистемБИП = ОбщегоНазначения.ОбщийМодуль("ИнтеграцияПодсистемБИП");
	МодульИнтеграцияПодсистемБИП.ИнтернетПоддержкаИСервисы_ПриСозданииНаСервере(ЭтотОбъект);
КонецПроцедуры

&НаСервере
Процедура УстановитьДоступность(РеквизитПутьКДанным = "")
	
	Если Не Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		Возврат;
	КонецЕсли;
	
	Если (РеквизитПутьКДанным = "НаборКонстант.ИспользоватьОнлайнПоддержку" Или РеквизитПутьКДанным = "")
		И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ВызовОнлайнПоддержки") Тогда
		Элементы.ГруппаНастройкаОнлайнПоддержки.Доступность = НаборКонстант.ИспользоватьОнлайнПоддержку;
	КонецЕсли;
	
	Если (РеквизитПутьКДанным = "НаборКонстант.ИспользоватьСервисСклоненияMorpher" Или РеквизитПутьКДанным = "")
		И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.СклонениеПредставленийОбъектов") Тогда
		
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
			Элементы, "ГруппаНастройкаСклонения", "Доступность",
			НаборКонстант.ИспользоватьСервисСклоненияMorpher);
			
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция СохранитьЗначениеРеквизита(РеквизитПутьКДанным)
	
	ЧастиИмени = СтрРазделить(РеквизитПутьКДанным, ".");
	Если ЧастиИмени.Количество() <> 2 Тогда
		Возврат "";
	КонецЕсли;
	
	ИмяКонстанты = ЧастиИмени[1];
	КонстантаМенеджер = Константы[ИмяКонстанты];
	КонстантаЗначение = НаборКонстант[ИмяКонстанты];
	
	Если КонстантаМенеджер.Получить() <> КонстантаЗначение Тогда
		КонстантаМенеджер.Установить(КонстантаЗначение);
	КонецЕсли;
	
	Возврат ИмяКонстанты;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьПереключательОтправкиДанных(ВключитьЦентрМониторинга, ЦентрОбработкиИнформацииОПрограмме)
	Состояние = ?(ВключитьЦентрМониторинга, "1", "0") + ?(ЦентрОбработкиИнформацииОПрограмме, "1", "0");
	
	Если Состояние = "00" Тогда
		Результат = 2;
	ИначеЕсли Состояние = "01" Тогда
		Результат = 1;
	ИначеЕсли Состояние = "10" Тогда
		Результат = 0;
	ИначеЕсли Состояние = "11" Тогда
		// А такого быть не может...
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьПараметрыЦентраМониторинга()
	МодульЦентрМониторингаСлужебный = ОбщегоНазначения.ОбщийМодуль("ЦентрМониторингаСлужебный");
	ПараметрыЦентраМониторинга = МодульЦентрМониторингаСлужебный.ПолучитьПараметрыЦентраМониторингаВнешнийВызов();
	
	ПараметрыСервисаПоУмолчанию = МодульЦентрМониторингаСлужебный.ПолучитьПараметрыПоУмолчаниюВнешнийВызов();
	ПараметрыЦентраМониторинга.Вставить("СерверПоУмолчанию", ПараметрыСервисаПоУмолчанию.Сервер);
	ПараметрыЦентраМониторинга.Вставить("АдресРесурсаПоУмолчанию", ПараметрыСервисаПоУмолчанию.АдресРесурса);
	ПараметрыЦентраМониторинга.Вставить("ПортПоУмолчанию", ПараметрыСервисаПоУмолчанию.Порт);
	
	Возврат ПараметрыЦентраМониторинга;
КонецФункции

&НаСервереБезКонтекста
Процедура РазрешитьОтправлятьДанныеПриИзмененииНаСервере(ПараметрыЦентраМониторинга, РезультатЗапуска)
	МодульЦентрМониторингаСлужебный = ОбщегоНазначения.ОбщийМодуль("ЦентрМониторингаСлужебный");
	МодульЦентрМониторингаСлужебный.УстановитьПараметрыЦентраМониторингаВнешнийВызов(ПараметрыЦентраМониторинга);
	
	ВключитьЦентрМониторинга = ПараметрыЦентраМониторинга.ВключитьЦентрМониторинга;
	ЦентрОбработкиИнформацииОПрограмме = ПараметрыЦентраМониторинга.ЦентрОбработкиИнформацииОПрограмме;
	
	Результат = ПолучитьПереключательОтправкиДанных(ВключитьЦентрМониторинга, ЦентрОбработкиИнформацииОПрограмме);
	
	Если Результат = 0 Или Результат = 1 Тогда
		// Отправка ознакомительного пакета.
		РезультатЗапуска = МодульЦентрМониторингаСлужебный.ЗапускОтправкиОзнакомительногоПакета();
	КонецЕсли;
	
	Если Результат = 0 Тогда
		// Включение задания сбора и отправки статистики.
		РегЗадание = МодульЦентрМониторингаСлужебный.ПолучитьРегламентноеЗаданиеВнешнийВызов("СборИОтправкаСтатистики", Истина);
		МодульЦентрМониторингаСлужебный.УстановитьРасписаниеПоУмолчаниюВнешнийВызов(РегЗадание);
	ИначеЕсли Результат = 1 Тогда
		РегЗадание = МодульЦентрМониторингаСлужебный.ПолучитьРегламентноеЗаданиеВнешнийВызов("СборИОтправкаСтатистики", Истина);
		МодульЦентрМониторингаСлужебный.УстановитьРасписаниеПоУмолчаниюВнешнийВызов(РегЗадание);
	ИначеЕсли Результат = 2 Тогда
		МодульЦентрМониторингаСлужебный.УдалитьРегламентноеЗаданиеВнешнийВызов("СборИОтправкаСтатистики");
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ЦентрМониторингаАдресСервисаПриИзмененииНаСервере(СтруктураАдреса)
	ПараметрыЦентраМониторинга = Новый Структура();
	ПараметрыЦентраМониторинга.Вставить("Сервер", СтруктураАдреса.Хост);
	ПараметрыЦентраМониторинга.Вставить("АдресРесурса", СтруктураАдреса.ПутьНаСервере);
	ПараметрыЦентраМониторинга.Вставить("Порт", СтруктураАдреса.Порт);
	ПараметрыЦентраМониторинга.Вставить("ЗащищенноеСоединение", СтруктураАдреса.ЗащищенноеСоединение);
	
	МодульЦентрМониторингаСлужебный = ОбщегоНазначения.ОбщийМодуль("ЦентрМониторингаСлужебный");
	МодульЦентрМониторингаСлужебный.УстановитьПараметрыЦентраМониторингаВнешнийВызов(ПараметрыЦентраМониторинга);
КонецПроцедуры

&НаКлиенте
Процедура ОбсужденияНастроитьИнтеграциюСВнешнимиСистемами(Команда)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.Обсуждения") Тогда
		МодульОбсужденияСлужебныйКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОбсужденияСлужебныйКлиент");
		МодульОбсужденияСлужебныйКлиент.ПоказатьНастройкуИнтеграцииСВнешнимиСистемами();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
