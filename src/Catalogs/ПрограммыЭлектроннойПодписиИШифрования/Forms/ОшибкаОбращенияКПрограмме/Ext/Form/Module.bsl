﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЭлектроннаяПодписьСлужебный.УстановитьЗаголовокОшибки(ЭтотОбъект,
		Параметры.ЗаголовокФормы);
	
	ЭтоПолноправныйПользователь = Пользователи.ЭтоПолноправныйПользователь(,, Ложь);
	
	ОшибкаНаКлиенте = Параметры.ОшибкаНаКлиенте;
	ОшибкаНаСервере = Параметры.ОшибкаНаСервере;
	
	ДобавитьОшибки(ОшибкаНаКлиенте);
	ДобавитьОшибки(ОшибкаНаСервере, Истина);
	
	Элементы.ОшибкиКартинка.Видимость =
		  Ошибки.НайтиСтроки(Новый Структура("ОшибкаНаСервере", Ложь)).Количество() <> 0
		И Ошибки.НайтиСтроки(Новый Структура("ОшибкаНаСервере", Истина)).Количество() <> 0;
	
	Элементы.Ошибки.ВысотаВСтрокахТаблицы = Мин(Ошибки.Количество(), 3);
	
	ОписаниеОшибки = ЭлектроннаяПодписьСлужебныйКлиентСервер.ОбщееОписаниеОшибки(
		ОшибкаНаКлиенте, ОшибкаНаСервере);
	
	ПоказатьИнструкцию                = Параметры.ПоказатьИнструкцию;
	ПоказатьПереходКНастройкеПрограмм = Параметры.ПоказатьПереходКНастройкеПрограмм;
	ПоказатьУстановкуРасширения       = Параметры.ПоказатьУстановкуРасширения;
	
	ОпределитьВозможности(ПоказатьИнструкцию, ПоказатьПереходКНастройкеПрограмм, ПоказатьУстановкуРасширения,
		ОшибкаНаКлиенте, ЭтоПолноправныйПользователь);
	
	ОпределитьВозможности(ПоказатьИнструкцию, ПоказатьПереходКНастройкеПрограмм, ПоказатьУстановкуРасширения,
		ОшибкаНаСервере, ЭтоПолноправныйПользователь);
	
	Если Не ПоказатьИнструкцию Тогда
		Элементы.Инструкция.Видимость = Ложь;
	КонецЕсли;
	
	ПоказатьУстановкуРасширения = ПоказатьУстановкуРасширения И Не Параметры.РасширениеПодключено;
	
	Если Не ПоказатьУстановкуРасширения Тогда
		Элементы.ФормаУстановитьРасширение.Видимость = Ложь;
	КонецЕсли;
	
	Если Не ПоказатьПереходКНастройкеПрограмм Тогда
		Элементы.ФормаПерейтиКНастройкеПрограмм.Видимость = Ложь;
	КонецЕсли;
	
	ДополнительныеДанные = Параметры.ДополнительныеДанные;
	
	Если ЗначениеЗаполнено(ДополнительныеДанные)
	   И ТипЗнч(ДополнительныеДанные.НеподписанныеДанные) = Тип("Структура") Тогда
		
		ЭлектроннаяПодписьСлужебный.ЗарегистрироватьПодписаниеДанныхВЖурнале(
			ДополнительныеДанные.НеподписанныеДанные, ОписаниеОшибки);
		
		ДополнительныеДанные.НеподписанныеДанные = Неопределено;
	КонецЕсли;
	
	ЭлектроннаяПодписьСлужебный.СброситьРазмерыИПоложениеОкна(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если Ошибки.Количество() = 1
	 Или Ошибки.Количество() = 2
	   И Ошибки[0].ОшибкаНаСервере <> Ошибки[1].ОшибкаНаСервере Тогда
		
		Отказ = Истина;
		
		Поток = Новый ПотокВПамяти;
		Поток.НачатьПолучениеРазмера(
			Новый ОписаниеОповещения("ПриОткрытииПродолжение", ЭтотОбъект));
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ТипичныеПроблемыОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ЭлектроннаяПодписьКлиент.ОткрытьИнструкциюПоТипичнымПроблемамПриРаботеСПрограммами();
	
КонецПроцедуры

&НаКлиенте
Процедура ИнформацияДляПоддержкиОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ТекстОшибок = "";
	ОписаниеФайлов = Новый Массив;
	Если ЗначениеЗаполнено(ДополнительныеДанные) Тогда
		ЭлектроннаяПодписьСлужебныйВызовСервера.ДобавитьОписаниеДополнительныхДанных(
			ДополнительныеДанные, ОписаниеФайлов, ТекстОшибок);
	КонецЕсли;
	
	ТекстОшибок = ТекстОшибок + ОписаниеОшибки;
	ЭлектроннаяПодписьСлужебныйКлиент.СформироватьТехническуюИнформацию(ТекстОшибок, , ОписаниеФайлов);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыОшибки

&НаКлиенте
Процедура ОшибкиВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Если Поле = Элементы.ОшибкиПодробнее Тогда
		
		ТекущиеДанные = Элементы.Ошибки.ТекущиеДанные;
		
		ПараметрыОшибки = Новый Структура;
		ПараметрыОшибки.Вставить("ЗаголовокПредупреждения", Заголовок);
		ПараметрыОшибки.Вставить(?(ТекущиеДанные.ОшибкаНаСервере,
			"ТекстОшибкиСервер", "ТекстОшибкиКлиент"), ТекущиеДанные.ОписаниеСЗаголовком);
		
		ОткрытьФорму("ОбщаяФорма.РасширенноеПредставлениеОшибки", ПараметрыОшибки, ЭтотОбъект);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПерейтиКНастройкеПрограмм(Команда)
	
	Закрыть();
	ЭлектроннаяПодписьКлиент.ОткрытьНастройкиЭлектроннойПодписиИШифрования("Программы");
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьРасширение(Команда)
	
	ЭлектроннаяПодписьКлиент.УстановитьРасширение(Истина);
	Закрыть();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Продолжение процедуры ПриОткрытии.
&НаКлиенте
Процедура ПриОткрытииПродолжение(Результат, Контекст) Экспорт
	
	ПараметрыОшибки = Новый Структура;
	ПараметрыОшибки.Вставить("ЗаголовокПредупреждения", Заголовок);
	ПараметрыОшибки.Вставить(?(Ошибки[0].ОшибкаНаСервере,
		"ТекстОшибкиСервер", "ТекстОшибкиКлиент"), Ошибки[0].ОписаниеСЗаголовком);
	
	Если Ошибки.Количество() > 1 Тогда
		ПараметрыОшибки.Вставить(?(Ошибки[1].ОшибкаНаСервере,
			"ТекстОшибкиСервер", "ТекстОшибкиКлиент"), Ошибки[1].ОписаниеСЗаголовком);
	КонецЕсли;
	
	ПараметрыОшибки.Вставить("ПоказатьТребуетсяПомощь", Истина);
	ПараметрыОшибки.Вставить("ПоказатьИнструкцию", ПоказатьИнструкцию);
	ПараметрыОшибки.Вставить("ПоказатьПереходКНастройкеПрограмм", ПоказатьПереходКНастройкеПрограмм);
	ПараметрыОшибки.Вставить("ПоказатьУстановкуРасширения", ПоказатьУстановкуРасширения);
	ПараметрыОшибки.Вставить("ОписаниеОшибки", ОписаниеОшибки);
	ПараметрыОшибки.Вставить("ДополнительныеДанные", ДополнительныеДанные);
	
	ОбработкаПродолжения = ОписаниеОповещенияОЗакрытии;
	ОписаниеОповещенияОЗакрытии = Неопределено;
	ОткрытьФорму("ОбщаяФорма.РасширенноеПредставлениеОшибки", ПараметрыОшибки, ЭтотОбъект,,,, ОбработкаПродолжения);
	
КонецПроцедуры

&НаСервере
Процедура ОпределитьВозможности(Инструкция, НастройкаПрограмм, Расширение, Ошибка, ЭтоПолноправныйПользователь)
	
	ОпределитьВозможностиПоСвойствам(Инструкция, НастройкаПрограмм, Расширение, Ошибка, ЭтоПолноправныйПользователь);
	
	Если Не Ошибка.Свойство("Ошибки")
		Или ТипЗнч(Ошибка.Ошибки) <> Тип("Массив") Тогда
		
		Возврат;
	КонецЕсли;
	
	Для каждого ТекущаяОшибка Из Ошибка.Ошибки Цикл
		ОпределитьВозможностиПоСвойствам(Инструкция, НастройкаПрограмм,
			Расширение, ТекущаяОшибка, ЭтоПолноправныйПользователь);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ОпределитьВозможностиПоСвойствам(Инструкция, НастройкаПрограмм, Расширение, Ошибка, ЭтоПолноправныйПользователь)
	
	Если Ошибка.Свойство("НастройкаПрограмм")
		И Ошибка.НастройкаПрограмм = Истина Тогда
		
		НастройкаПрограмм = ЭтоПолноправныйПользователь
			Или Не Ошибка.Свойство("КАдминистратору")
			Или Ошибка.КАдминистратору <> Истина;
		
	КонецЕсли;
	
	Если Ошибка.Свойство("Инструкция")
		И Ошибка.Инструкция = Истина Тогда
		
		Инструкция = Истина;
	КонецЕсли;
	
	Если Ошибка.Свойство("НетРасширения")
		И Ошибка.НетРасширения = Истина Тогда
		
		Расширение = Истина;
	КонецЕсли;
	
КонецПроцедуры

// Параметры:
//   ОписаниеОшибок - ДанныеФормыКоллекция:
//   * Ошибки - Массив из Структура
//   ОшибкаНаСервере - Булево
//
&НаСервере
Процедура ДобавитьОшибки(ОписаниеОшибок, ОшибкаНаСервере = Ложь)
	
	Если Не ЗначениеЗаполнено(ОписаниеОшибок) Тогда
		Возврат;
	КонецЕсли;
	
	Если ОписаниеОшибок.Свойство("Ошибки")
		И ТипЗнч(ОписаниеОшибок.Ошибки) = Тип("Массив")
		И ОписаниеОшибок.Ошибки.Количество() > 0 Тогда
		
		СвойстваОшибок = ОписаниеОшибок.Ошибки; // Массив Из см. ЭлектроннаяПодписьСлужебныйКлиентСервер.НовыеСвойстваОшибки
		Для Каждого СвойстваОшибки Из СвойстваОшибок Цикл
			
			ОписаниеСЗаголовком = "";
			Если ЗначениеЗаполнено(СвойстваОшибки.ЗаголовокОшибки) Тогда
				ОписаниеСЗаголовком = СвойстваОшибки.ЗаголовокОшибки + Символы.ПС;
			ИначеЕсли ЗначениеЗаполнено(ОписаниеОшибок.ЗаголовокОшибки) Тогда
				ОписаниеСЗаголовком = ОписаниеОшибок.ЗаголовокОшибки + Символы.ПС;
			КонецЕсли;
			Описание = "";
			Если ЗначениеЗаполнено(СвойстваОшибки.Программа) Тогда
				Описание = Описание + Строка(СвойстваОшибки.Программа) + ":" + Символы.ПС;
			КонецЕсли;
			Описание = Описание + СвойстваОшибки.Описание;
			ОписаниеСЗаголовком = ОписаниеСЗаголовком + Описание;
			
			СтрокаОшибки = Ошибки.Добавить();
			СтрокаОшибки.Причина = Описание;
			СтрокаОшибки.ОписаниеСЗаголовком = ОписаниеСЗаголовком;
			СтрокаОшибки.Подробнее = НСтр("ru = 'Подробнее'") + "...";
			СтрокаОшибки.ОшибкаНаСервере = ОшибкаНаСервере;
			СтрокаОшибки.Картинка = ?(ОшибкаНаСервере,
				БиблиотекаКартинок.КомпьютерСервер,
				БиблиотекаКартинок.КомпьютерКлиент);
			
		КонецЦикла;
	Иначе
		СтрокаОшибки = Ошибки.Добавить();
		СтрокаОшибки.Причина = ОписаниеОшибок.ОписаниеОшибки;
		СтрокаОшибки.ОписаниеСЗаголовком = ОписаниеОшибок.ОписаниеОшибки;
		СтрокаОшибки.Подробнее = НСтр("ru = 'Подробнее'") + "...";
		СтрокаОшибки.ОшибкаНаСервере = ОшибкаНаСервере;
		СтрокаОшибки.Картинка = ?(ОшибкаНаСервере,
			БиблиотекаКартинок.КомпьютерСервер,
			БиблиотекаКартинок.КомпьютерКлиент);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
