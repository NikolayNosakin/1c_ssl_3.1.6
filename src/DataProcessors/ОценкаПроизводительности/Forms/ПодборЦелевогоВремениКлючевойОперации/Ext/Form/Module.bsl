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
	Параметры.Свойство("КлючеваяОперация", КлючеваяОперация);
	Если Не ЗначениеЗаполнено(Период.ДатаНачала) Тогда
		Период.ДатаНачала = ДобавитьМесяц(НачалоДня(ТекущаяДатаСеанса()), -3);
	КонецЕсли;
	Если Не ЗначениеЗаполнено(Период.ДатаОкончания) Тогда
		Период.ДатаОкончания = НачалоДня(ТекущаяДатаСеанса());
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПодобратьЦелевоеВремя(Команда)                             
	РезультатПроверки = ПроверкаЗаполнения();
	Если РезультатПроверки Тогда
		
		ПараметрыПодбора = Новый Структура;
		ПараметрыПодбора.Вставить("КлючеваяОперация", КлючеваяОперация);
		ПараметрыПодбора.Вставить("ДатаНачала", Период.ДатаНачала);
		ПараметрыПодбора.Вставить("ДатаОкончания", Период.ДатаОкончания);
		ПараметрыПодбора.Вставить("ЦелевойAPDEX", ТекущийAPDEX);		
		РезультатПодбора = ПодборЦелевоеВремяНаСервере(ПараметрыПодбора);
		Если РезультатПодбора.Свойство("ОписаниеОшибки") Тогда
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = РезультатПодбора.ОписаниеОшибки;
			Сообщение.Сообщить();
			Возврат;
		КонецЕсли;
		РасчетныйAPDEX = РезультатПодбора.РасчетныйAPDEX;
		КоличествоЗамеров = РезультатПодбора.КоличествоЗамеров;
		ЦелевоеВремя = РезультатПодбора.ЦелевоеВремя;
		
		ДиаграммаЗамеровВремени.ТипДиаграммы = ТипДиаграммы.График;
		ДиаграммаЗамеровВремени.ОбластьПостроения.ШкалаЗначений.ТекстЗаголовка = НСтр("ru = 'Количество замеров, шт'");
		ДиаграммаЗамеровВремени.Очистить();
		Серия = ДиаграммаЗамеровВремени.Серии.Добавить("Время выполнения, с");		
		Для Каждого Замер Из РезультатПодбора.Замеры Цикл
			Для Каждого Запись Из Замер Цикл
				Точка = ДиаграммаЗамеровВремени.Точки.Добавить(Запись.Ключ);
				Точка.Текст = Формат(Запись.Ключ, "ЧН=0");
				ДиаграммаЗамеровВремени.УстановитьЗначение(Точка, Серия, Запись.Значение);
			КонецЦикла;
		КонецЦикла;		
	КонецЕсли;
КонецПроцедуры


#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Функция ПроверкаЗаполнения()
	Успешно = Истина;
	Если КлючеваяОперация.Пустая() Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = НСтр("ru = 'Не указана ключевая операция.'");
		Сообщение.Поле = "КлючеваяОперация";
		Сообщение.Сообщить();
		Успешно = Ложь;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(ТекущийApdex) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = НСтр("ru = 'Не указан текущий APDEX.'");
		Сообщение.Поле = "ТекущийApdex";
		Сообщение.Сообщить();
		Успешно = Ложь;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(Период.ДатаНачала) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = НСтр("ru = 'Не указана дата начала периода.'");
		Сообщение.Поле = "Период";
		Сообщение.Сообщить();
		Успешно = Ложь;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(Период.ДатаОкончания) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = НСтр("ru = 'Не указана дата окончания периода.'");
		Сообщение.Поле = "Период";
		Сообщение.Сообщить();
		Успешно = Ложь;
	КонецЕсли;
	Возврат Успешно;
КонецФункции

&НаСервереБезКонтекста
Функция ПодборЦелевоеВремяНаСервере(ПараметрыПодбора)
	
	РезультатПодбора = Новый Структура;
	РезультатПодбора.Вставить("Замеры", Новый Массив);
	РезультатПодбора.Вставить("КоличествоЗамеров", 0);
	РезультатПодбора.Вставить("ЦелевоеВремя", 0);
	РезультатПодбора.Вставить("РасчетныйAPDEX", 0);
	Минимум = 0;
	Максимум = 0;
	ДопустимаяРазница = 0.01;
	МаксимальноеКоличествоИтераций = 1000;
	Счетчик = 0;
	МВТ = Новый МенеджерВременныхТаблиц;
	
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	                      |	Замеры.ВремяВыполнения КАК ВремяВыполнения,
	                      |	1 КАК КоличествоЗамеров
	                      |ПОМЕСТИТЬ ЗамерыОперации
	                      |ИЗ
	                      |	РегистрСведений.ЗамерыВремени КАК Замеры
	                      |ГДЕ
	                      |	Замеры.ДатаНачалаЗамера МЕЖДУ &ДатаНачала И &ДатаОкончания
	                      |	И Замеры.КлючеваяОперация = &КлючеваяОперация
	                      |;
	                      |
	                      |////////////////////////////////////////////////////////////////////////////////
	                      |ВЫБРАТЬ
	                      |	ЕСТЬNULL(МАКСИМУМ(ЗамерыОперации.ВремяВыполнения), 0) КАК МАКСИМУМВремяВыполнения,
	                      |	ЕСТЬNULL(МИНИМУМ(ЗамерыОперации.ВремяВыполнения), 0) КАК МИНИМУМВремяВыполнения,
	                      |	ЕСТЬNULL(СУММА(ЗамерыОперации.КоличествоЗамеров), 0) КАК КоличествоЗамеров
	                      |ИЗ
	                      |	ЗамерыОперации КАК ЗамерыОперации");
	Запрос.МенеджерВременныхТаблиц = МВТ;
	Запрос.УстановитьПараметр("ДатаНачала", (ПараметрыПодбора.ДатаНачала - Дата(1,1,1)) * 1000);	
	Запрос.УстановитьПараметр("ДатаОкончания", (ПараметрыПодбора.ДатаОкончания - Дата(1,1,1)) * 1000);
	Запрос.УстановитьПараметр("КлючеваяОперация", ПараметрыПодбора.КлючеваяОперация);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Минимум = Выборка.МИНИМУМВремяВыполнения;
		Максимум = Выборка.МАКСИМУМВремяВыполнения;
		РезультатПодбора.КоличествоЗамеров = Выборка.КоличествоЗамеров;
	Иначе
		РезультатПодбора.Вставить("ОписаниеОшибки", НСтр("ru = 'Не удалось получить данные о замерах, попробуйте изменить настройки.'"));
		Возврат РезультатПодбора;
	КонецЕсли;
	
	Если РезультатПодбора.КоличествоЗамеров = 0 Тогда
		РезультатПодбора.Вставить("ОписаниеОшибки",
			ОценкаПроизводительностиКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Получено 0 замеров по ключевой операции %1. Измените период или выберите другую ключевую операцию.'"),
				ПараметрыПодбора.КлючеваяОперация));
		Возврат РезультатПодбора;
	КонецЕсли;
	
	ТекущееЦелевоеВремя = (Минимум + Максимум) / 2;
	РасчетныйAPDEX = ЗначениеAPDEX(МВТ, ТекущееЦелевоеВремя);
	Отклонение = Макс(РасчетныйAPDEX - ПараметрыПодбора.ЦелевойAPDEX, ПараметрыПодбора.ЦелевойAPDEX - РасчетныйAPDEX);
	
	Пока Отклонение > ДопустимаяРазница
		И Счетчик < МаксимальноеКоличествоИтераций
		Цикл
		Счетчик = Счетчик + 1;
		ДанныеМинимум = ОтклонениеAPDEX(Минимум, ТекущееЦелевоеВремя, МВТ, ПараметрыПодбора.ЦелевойAPDEX);
		ДанныеМаксимум = ОтклонениеAPDEX(Максимум, ТекущееЦелевоеВремя, МВТ, ПараметрыПодбора.ЦелевойAPDEX);
		
		Если Максимум - Минимум <= 0.002 Тогда
			Прервать;
		ИначеЕсли ДанныеМинимум.Отклонение <= ДанныеМаксимум.Отклонение Тогда
			Максимум = ТекущееЦелевоеВремя;
			ТекущееЦелевоеВремя = ДанныеМинимум.ТекущееЦелевоеВремя;			
			Отклонение = ДанныеМинимум.Отклонение;
			РасчетныйAPDEX = ДанныеМинимум.APDEX;
		ИначеЕсли ДанныеМинимум.Отклонение > ДанныеМаксимум.Отклонение Тогда
			Минимум = ТекущееЦелевоеВремя;
			ТекущееЦелевоеВремя = ДанныеМаксимум.ТекущееЦелевоеВремя;			
			Отклонение = ДанныеМаксимум.Отклонение;
			РасчетныйAPDEX = ДанныеМаксимум.APDEX;
		КонецЕсли;
		
	КонецЦикла;
	
	РезультатПодбора.ЦелевоеВремя = ТекущееЦелевоеВремя;
	РезультатПодбора.РасчетныйAPDEX = РасчетныйAPDEX; 
	РезультатПодбора.Замеры = СоответствиеЗамеров(МВТ);
		
	Возврат РезультатПодбора;
	
КонецФункции

&НаСервереБезКонтекста
Функция ОтклонениеAPDEX(ГраницаИнтервала, ТекущееЦелевоеВремя, МенеджерВременныхТаблиц, ЦелевойAPDEX)
	ТекущееЦелевоеВремяНовое = ОКР((ГраницаИнтервала + ТекущееЦелевоеВремя) / 2, 3);
	APDEX = ЗначениеAPDEX(МенеджерВременныхТаблиц, ТекущееЦелевоеВремяНовое);
	Отклонение = Макс(APDEX - ЦелевойAPDEX, ЦелевойAPDEX - APDEX);	
	Возврат Новый Структура("ТекущееЦелевоеВремя, APDEX, Отклонение", ТекущееЦелевоеВремяНовое, APDEX, Отклонение)
КонецФункции

&НаСервереБезКонтекста
Функция СоответствиеЗамеров(МенеджерВременныхТаблиц)
	СоответствиеЗамеров = Новый Массив;
	Запрос = Новый Запрос("ВЫБРАТЬ
	                      |	ВЫРАЗИТЬ(ЗамерыОперации.ВремяВыполнения КАК ЧИСЛО(15, 0)) КАК ВремяВыполнения,
	                      |	СУММА(ЗамерыОперации.КоличествоЗамеров) КАК КоличествоЗамеров
	                      |ИЗ
	                      |	ЗамерыОперации КАК ЗамерыОперации
	                      |
	                      |СГРУППИРОВАТЬ ПО
	                      |	ВЫРАЗИТЬ(ЗамерыОперации.ВремяВыполнения КАК ЧИСЛО(15, 0))
	                      |
	                      |УПОРЯДОЧИТЬ ПО
	                      |	ВремяВыполнения");
	Запрос.МенеджерВременныхТаблиц = МенеджерВременныхТаблиц;
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Замер = Новый Соответствие;
		Замер.Вставить(Выборка.ВремяВыполнения, Выборка.КоличествоЗамеров);
		СоответствиеЗамеров.Добавить(Замер);
	КонецЦикла;
	Возврат СоответствиеЗамеров;
КонецФункции

&НаСервереБезКонтекста
Функция ЗначениеAPDEX(МенеджерВременныхТаблиц, ТекущееЦелевоеВремя)
	Запрос = Новый Запрос("ВЫБРАТЬ
	               |	СУММА(ВЫБОР
	               |			КОГДА ЗамерыОперации.ВремяВыполнения <= &ЦелевоеВремя
	               |				ТОГДА ЗамерыОперации.КоличествоЗамеров
	               |			ИНАЧЕ 0
	               |		КОНЕЦ) КАК T,
	               |	СУММА(ВЫБОР
	               |			КОГДА ЗамерыОперации.ВремяВыполнения > &ЦелевоеВремя
	               |					И ЗамерыОперации.ВремяВыполнения <= 4 * &ЦелевоеВремя
	               |				ТОГДА ЗамерыОперации.КоличествоЗамеров
	               |			ИНАЧЕ 0
	               |		КОНЕЦ) КАК T_4T,
	               |	СУММА(ЗамерыОперации.КоличествоЗамеров) КАК N,
	               |	ЕСТЬNULL((СУММА(ВЫБОР
	               |			КОГДА ЗамерыОперации.ВремяВыполнения <= &ЦелевоеВремя
	               |				ТОГДА ЗамерыОперации.КоличествоЗамеров
	               |			ИНАЧЕ 0
	               |		КОНЕЦ) + СУММА(ВЫБОР
	               |			КОГДА ЗамерыОперации.ВремяВыполнения > &ЦелевоеВремя
	               |					И ЗамерыОперации.ВремяВыполнения <= 4 * &ЦелевоеВремя
	               |				ТОГДА ЗамерыОперации.КоличествоЗамеров
	               |			ИНАЧЕ 0
	               |		КОНЕЦ) / 2) / СУММА(ЗамерыОперации.КоличествоЗамеров),0) КАК APDEX
	               |ИЗ
	               |	ЗамерыОперации КАК ЗамерыОперации");
	Запрос.МенеджерВременныхТаблиц = МенеджерВременныхТаблиц;
	Запрос.УстановитьПараметр("ЦелевоеВремя", ТекущееЦелевоеВремя);
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	Возврат Окр(Выборка.APDEX, 3);
КонецФункции

#КонецОбласти