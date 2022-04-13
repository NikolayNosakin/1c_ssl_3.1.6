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
	
	Если Объект.Ссылка.Пустая() Тогда
		ЗаполнитьДаннымиТекущегоГода(Параметры.ЗначениеКопирования);
		УстановитьСвойстваПоляБазовогоКалендаря(ЭтотОбъект);
	КонецЕсли;
	
	ЦветаВидовДней = Новый ФиксированноеСоответствие(Справочники.ПроизводственныеКалендари.ЦветаОформленияВидовДнейПроизводственногоКалендаря());
	
	СписокВидовДня = Справочники.ПроизводственныеКалендари.СписокВидовДня();
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РаботаВМоделиСервиса.ОбменДаннымиВМоделиСервиса") Тогда
		МодульАвтономнаяРабота = ОбщегоНазначения.ОбщийМодуль("АвтономнаяРабота");
		МодульАвтономнаяРабота.ОбъектПриЧтенииНаСервере(ТекущийОбъект, ЭтотОбъект.ТолькоПросмотр);
	КонецЕсли;
	
	ЗаполнитьДаннымиТекущегоГода();
	
	ЕстьБазовыйКалендарь = ЗначениеЗаполнено(Объект.БазовыйКалендарь);
	УстановитьСвойстваПоляБазовогоКалендаря(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	НачатьУстановкуВидимостиБазовогоКалендаря();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	Если ВРег(ИсточникВыбора.ИмяФормы) = ВРег("ОбщаяФорма.ВыборДаты") Тогда
		Если ВыбранноеЗначение = Неопределено Тогда
			Возврат;
		КонецЕсли;
		ВыделенныеДаты = Элементы.Календарь.ВыделенныеДаты;
		Если ВыделенныеДаты.Количество() = 0 Или Год(ВыделенныеДаты[0]) <> НомерТекущегоГода Тогда
			Возврат;
		КонецЕсли;
		ДатаПереноса = ВыделенныеДаты[0];
		ПеренестиВидДня(ДатаПереноса, ВыбранноеЗначение);
		Элементы.Календарь.Обновить();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)
	
	Если ЕстьБазовыйКалендарь И Не ЗначениеЗаполнено(Объект.БазовыйКалендарь) Тогда
		ТекстСообщения = НСтр("ru = 'Федеральный календарь не заполнен.'");
		ОбщегоНазначения.СообщитьПользователю(ТекстСообщения, , , "Объект.БазовыйКалендарь", Отказ);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Перем НомерГода;
	
	Если Не ПараметрыЗаписи.Свойство("НомерГода", НомерГода) Тогда
		НомерГода = НомерТекущегоГода;
	КонецЕсли;
	
	ЗаписатьДанныеПроизводственногоКалендаря(НомерГода, ТекущийОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура НомерТекущегоГодаПриИзменении(Элемент)
	
	ЗаписыватьДанныеГрафика = Ложь;
	Если Модифицированность Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Записать измененные данные за %1 год?'"), Формат(НомерПредыдущегоГода, "ЧГ=0"));
		Оповещение = Новый ОписаниеОповещения("НомерТекущегоГодаПриИзмененииЗавершение", ЭтотОбъект);
		ПоказатьВопрос(Оповещение, ТекстСообщения, РежимДиалогаВопрос.ДаНет);
		Возврат;
	КонецЕсли;
	
	ОбработатьИзменениеГода(ЗаписыватьДанныеГрафика);
	
	Модифицированность = Ложь;
	
	Элементы.Календарь.Обновить();
	
КонецПроцедуры

&НаКлиенте
Процедура КалендарьПриВыводеПериода(Элемент, ОформлениеПериода)
	
	Для Каждого СтрокаОформленияПериода Из ОформлениеПериода.Даты Цикл
		ЦветОформленияДня = ЦветаВидовДней.Получить(ВидыДней.Получить(СтрокаОформленияПериода.Дата));
		Если ЦветОформленияДня = Неопределено Тогда
			ЦветОформленияДня = ОбщегоНазначенияКлиент.ЦветСтиля("ВидДняПроизводственногоКалендаряНеУказанЦвет");
		КонецЕсли;
		СтрокаОформленияПериода.ЦветТекста = ЦветОформленияДня;
		Если НерабочиеДаты.Найти(СтрокаОформленияПериода.Дата) <> Неопределено Тогда
			СтрокаОформленияПериода.ЦветФона = ОбщегоНазначенияКлиент.ЦветСтиля("НерабочийПериодПроизводственногоКалендаряФон");
		КонецЕсли; 
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ЕстьБазовыйКалендарьПриИзменении(Элемент)
	
	УстановитьСвойстваПоляБазовогоКалендаря(ЭтотОбъект);
	
	Если Не ЕстьБазовыйКалендарь Тогда
		Объект.БазовыйКалендарь = Неопределено;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура БазовыйКалендарьПриИзменении(Элемент)
	ПрочитатьНерабочиеДаты();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ИзменитьДень(Команда)
	
	ВыделенныеДаты = Элементы.Календарь.ВыделенныеДаты;
	
	Если ВыделенныеДаты.Количество() > 0 И Год(ВыделенныеДаты[0]) = НомерТекущегоГода Тогда
		Оповещение = Новый ОписаниеОповещения("ИзменитьДеньЗавершение", ЭтотОбъект, ВыделенныеДаты);
		ПоказатьВыборИзСписка(Оповещение, СписокВидовДня, , СписокВидовДня.НайтиПоЗначению(ВидыДней.Получить(ВыделенныеДаты[0])));
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПеренестиДень(Команда)
	
	ВыделенныеДаты = Элементы.Календарь.ВыделенныеДаты;
	
	Если ВыделенныеДаты.Количество() = 0 Или Год(ВыделенныеДаты[0]) <> НомерТекущегоГода Тогда
		Возврат;
	КонецЕсли;
		
	ДатаПереноса = ВыделенныеДаты[0];
	ВидДня = ВидыДней.Получить(ДатаПереноса);
	
	ПараметрыВыбораДаты = Новый Структура(
		"НачальноеЗначение, 
		|НачалоПериодаОтображения, 
		|КонецПериодаОтображения, 
		|Заголовок, 
		|ПоясняющийТекст");
		
	ПараметрыВыбораДаты.НачальноеЗначение = ДатаПереноса;
	ПараметрыВыбораДаты.НачалоПериодаОтображения = НачалоГода(Календарь);
	ПараметрыВыбораДаты.КонецПериодаОтображения = КонецГода(Календарь);
	ПараметрыВыбораДаты.Заголовок = НСтр("ru = 'Выбор даты переноса'");
	
	ПараметрыВыбораДаты.ПоясняющийТекст = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Выберите дату, на которую будет осуществлен перенос дня %1 (%2)'"), 
		Формат(ДатаПереноса, "ДФ='д ММММ'"), // АПК:1367 Хорошего решения нет, считаем сохранение порядка дата + месяц приемлемым решением в этом месте
		ВидДня);
	
	ОткрытьФорму("ОбщаяФорма.ВыборДаты", ПараметрыВыбораДаты, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьПоУмолчанию(Команда)
	
	ЗаполнитьДаннымиПоУмолчанию();
	
	Элементы.Календарь.Обновить();
	
КонецПроцедуры

&НаКлиенте
Процедура Печать(Команда)
	
	Если Объект.Ссылка.Пустая() Тогда
		Обработчик = Новый ОписаниеОповещения("ПечатьЗавершение", ЭтотОбъект);
		ПоказатьВопрос(
			Обработчик,
			НСтр("ru = 'Данные производственного календаря еще не записаны.
                  |Печать возможна только после записи данных.
                  |
                  |Записать?'"),
			РежимДиалогаВопрос.ДаНет,
			,
			КодВозвратаДиалога.Да);
		Возврат;
	КонецЕсли;
	
	ПечатьЗавершение(-1);
		
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаполнитьДаннымиТекущегоГода(ЗначениеКопирования = Неопределено)
	
	// Заполняет форму данными текущего года.
	
	НастроитьПолеКалендаря();
	
	СсылкаНаКалендарь = Объект.Ссылка;
	Если ЗначениеЗаполнено(ЗначениеКопирования) Тогда
		СсылкаНаКалендарь = ЗначениеКопирования;
		Объект.Наименование = Неопределено;
		Объект.Код = Неопределено;
	КонецЕсли;
	
	ПрочитатьДанныеПроизводственногоКалендаря(СсылкаНаКалендарь, НомерТекущегоГода);
	ПрочитатьНерабочиеДаты();
	
КонецПроцедуры

&НаСервере
Процедура ПрочитатьДанныеПроизводственногоКалендаря(ПроизводственныйКалендарь, НомерГода)
	
	// Загрузка данных производственного календаря за указанный год.
	ПреобразоватьДанныеПроизводственногоКалендаря(
		Справочники.ПроизводственныеКалендари.ДанныеПроизводственногоКалендаря(ПроизводственныйКалендарь, НомерГода));
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДаннымиПоУмолчанию()
	
	// Заполняет форму данными производственного календаря, 
	// составленными на основе сведений о праздничных днях и переносах.
	
	КодБазовогоКалендаря = Неопределено;
	Если ЗначениеЗаполнено(Объект.БазовыйКалендарь) Тогда
		КодБазовогоКалендаря = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.БазовыйКалендарь, "Код");
	КонецЕсли;
	
	ДанныеПоУмолчанию = Справочники.ПроизводственныеКалендари.РезультатЗаполненияПроизводственногоКалендаряПоУмолчанию(
		Объект.Код, НомерТекущегоГода, КодБазовогоКалендаря);
		
	ПреобразоватьДанныеПроизводственногоКалендаря(ДанныеПоУмолчанию);

	Модифицированность = Истина;
	
КонецПроцедуры

&НаСервере
Процедура ПреобразоватьДанныеПроизводственногоКалендаря(ДанныеПроизводственногоКалендаря)
	
	// Данные производственного календаря используются в форме 
	// в виде соответствий ВидыДней и ПереносыДней.
	// Процедура заполняет эти соответствия.
	
	ВидыДнейСоответствие = Новый Соответствие;
	ПереносыДнейСоответствие = Новый Соответствие;
	
	Для Каждого СтрокаТаблицы Из ДанныеПроизводственногоКалендаря Цикл
		ВидыДнейСоответствие.Вставить(СтрокаТаблицы.Дата, СтрокаТаблицы.ВидДня);
		Если ЗначениеЗаполнено(СтрокаТаблицы.ДатаПереноса) Тогда
			ПереносыДнейСоответствие.Вставить(СтрокаТаблицы.Дата, СтрокаТаблицы.ДатаПереноса);
		КонецЕсли;
	КонецЦикла;
	
	ВидыДней = Новый ФиксированноеСоответствие(ВидыДнейСоответствие);
	ПереносыДней = Новый ФиксированноеСоответствие(ПереносыДнейСоответствие);
	
	ЗаполнитьПредставлениеПереносов(ЭтотОбъект);
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьДанныеПроизводственногоКалендаря(Знач НомерГода, Знач ТекущийОбъект = Неопределено)
	
	// Запись данных производственного календаря за указанный год.
	
	Если ТекущийОбъект = Неопределено Тогда
		ТекущийОбъект = РеквизитФормыВЗначение("Объект");
	КонецЕсли;
	
	ДанныеПроизводственногоКалендаря = Новый ТаблицаЗначений;
	ДанныеПроизводственногоКалендаря.Колонки.Добавить("Дата", Новый ОписаниеТипов("Дата"));
	ДанныеПроизводственногоКалендаря.Колонки.Добавить("ВидДня", Новый ОписаниеТипов("ПеречислениеСсылка.ВидыДнейПроизводственногоКалендаря"));
	ДанныеПроизводственногоКалендаря.Колонки.Добавить("ДатаПереноса", Новый ОписаниеТипов("Дата"));
	
	Для Каждого КлючИЗначение Из ВидыДней Цикл
		
		СтрокаТаблицы = ДанныеПроизводственногоКалендаря.Добавить();
		СтрокаТаблицы.Дата = КлючИЗначение.Ключ;
		СтрокаТаблицы.ВидДня = КлючИЗначение.Значение;
		
		// Если день перенесен с другой даты, вписываем дату переноса.
		ДатаПереноса = ПереносыДней.Получить(СтрокаТаблицы.Дата);
		Если ДатаПереноса <> Неопределено 
			И ДатаПереноса <> СтрокаТаблицы.Дата Тогда
			СтрокаТаблицы.ДатаПереноса = ДатаПереноса;
		КонецЕсли;
		
	КонецЦикла;
	
	Справочники.ПроизводственныеКалендари.ЗаписатьДанныеПроизводственногоКалендаря(ТекущийОбъект.Ссылка, НомерГода, ДанныеПроизводственногоКалендаря);
	
КонецПроцедуры

&НаСервере
Процедура ОбработатьИзменениеГода(ЗаписыватьДанныеГрафика)
	
	Если Не ЗаписыватьДанныеГрафика Тогда
		ЗаполнитьДаннымиТекущегоГода();
		Возврат;
	КонецЕсли;
	
	Если Объект.Ссылка.Пустая() Тогда
		Записать(Новый Структура("НомерГода", НомерПредыдущегоГода));
	Иначе
		ЗаписатьДанныеПроизводственногоКалендаря(НомерПредыдущегоГода);
	КонецЕсли;
	
	ЗаполнитьДаннымиТекущегоГода();	
	
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьВидыДней(ДатыДней, ВидДня)
	
	// Устанавливает дням по всем датам массива определенный вид.
	
	ВидыДнейСоответствие = Новый Соответствие(ВидыДней);
	
	Для Каждого ВыбраннаяДата Из ДатыДней Цикл
		ВидыДнейСоответствие.Вставить(ВыбраннаяДата, ВидДня);
	КонецЦикла;
	
	ВидыДней = Новый ФиксированноеСоответствие(ВидыДнейСоответствие);
	
КонецПроцедуры

&НаКлиенте
Процедура ПеренестиВидДня(ДатаПереноса, ДатаНазначения)
	
	// Нужно обменять местами два дня в календаре
	// - обменяться видами дня
	// - запомнить даты переноса
	//	* если переносимый день уже имеет дату переноса (уже был откуда-то перенесен), 
	//		используем имеющуюся дату переноса
	//	* если даты совпадают (день возвращен на "свое место") - удаляем такую запись.
	
	ВидыДнейСоответствие = Новый Соответствие(ВидыДней);
	
	ВидыДнейСоответствие.Вставить(ДатаНазначения, ВидыДней.Получить(ДатаПереноса));
	ВидыДнейСоответствие.Вставить(ДатаПереноса, ВидыДней.Получить(ДатаНазначения));
	
	ПереносыДнейСоответствие = Новый Соответствие(ПереносыДней);
	
	ВписатьДатуПереноса(ПереносыДнейСоответствие, ДатаПереноса, ДатаНазначения);
	ВписатьДатуПереноса(ПереносыДнейСоответствие, ДатаНазначения, ДатаПереноса);
	
	ВидыДней = Новый ФиксированноеСоответствие(ВидыДнейСоответствие);
	ПереносыДней = Новый ФиксированноеСоответствие(ПереносыДнейСоответствие);
	
	ЗаполнитьПредставлениеПереносов(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ВписатьДатуПереноса(ПереносыДнейСоответствие, ДатаПереноса, ДатаНазначения)
	
	// Заполняет в соответствии с датами переносов дней корректную дату переноса.
	
	ИсточникДняДатыНазначения = ПереносыДней.Получить(ДатаНазначения);
	Если ИсточникДняДатыНазначения = Неопределено Тогда
		ИсточникДняДатыНазначения = ДатаНазначения;
	КонецЕсли;
	
	Если ДатаПереноса = ИсточникДняДатыНазначения Тогда
		ПереносыДнейСоответствие.Удалить(ДатаПереноса);
	Иначе	
		ПереносыДнейСоответствие.Вставить(ДатаПереноса, ИсточникДняДатыНазначения);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ЗаполнитьПредставлениеПереносов(Форма)
	
	// Формирует представление переносов в виде списка значений.
	
	Форма.СписокПереносов.Очистить();
	Для Каждого КлючИЗначение Из Форма.ПереносыДней Цикл
		// С прикладной точки зрения переносится всегда выходной день на рабочий, 
		// поэтому из двух дат выбираем ту, которой соответствовал выходной день (сейчас соответствует рабочий).
		ДатаИсточник = КлючИЗначение.Ключ;
		ДатаПриемник = КлючИЗначение.Значение;
		ВидДня = Форма.ВидыДней.Получить(ДатаИсточник);
		Если ВидДня = ПредопределенноеЗначение("Перечисление.ВидыДнейПроизводственногоКалендаря.Суббота")
			Или ВидДня = ПредопределенноеЗначение("Перечисление.ВидыДнейПроизводственногоКалендаря.Воскресенье") Тогда
			// Обменяем даты местами, чтобы отобразить сведения о переносе как "А на Б", а не "Б на А".
			ДатаПереноса = ДатаПриемник;
			ДатаПриемник = ДатаИсточник;
			ДатаИсточник = ДатаПереноса;
		КонецЕсли;
		Если Форма.СписокПереносов.НайтиПоЗначению(ДатаИсточник) <> Неопределено 
			Или Форма.СписокПереносов.НайтиПоЗначению(ДатаПриемник) <> Неопределено Тогда
			// Перенос уже добавлен, пропускаем.
			Продолжить;
		КонецЕсли;
		Форма.СписокПереносов.Добавить(ДатаИсточник, ПредставлениеПереноса(ДатаИсточник, ДатаПриемник));
	КонецЦикла;
	Форма.СписокПереносов.СортироватьПоЗначению();
	
	УстановитьВидимостьСпискаПереносов(Форма);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ПредставлениеПереноса(ДатаИсточник, ДатаПриемник)
	
	Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'с %1 %2 на %3 %4'"),
		ДеньНеделиВФормулировкеСКакогоПереносим(ДатаИсточник),
		Формат(ДатаИсточник, "ДФ='д ММММ'"), // АПК:1367 Хорошего решения нет, считаем сохранение порядка дата + месяц приемлемым решением в этом месте
		ДеньНеделиВФормулировкеНаКакойПереносим(ДатаПриемник),
		Формат(ДатаПриемник, "ДФ='д ММММ'")); // АПК:1367 
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьВидимостьСпискаПереносов(Форма)
	
	ВидимостьСписка = Форма.СписокПереносов.Количество() > 0;
	ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Форма.Элементы, "СписокПереносов", "Видимость", ВидимостьСписка);
	
КонецПроцедуры

&НаСервере
Процедура НастроитьПолеКалендаря()
	
	Если НомерТекущегоГода = 0 Тогда
		НомерТекущегоГода = Год(ТекущаяДатаСеанса());
	КонецЕсли;
	НомерПредыдущегоГода = НомерТекущегоГода;
	
	Элементы.Календарь.НачалоПериодаОтображения	= Дата(НомерТекущегоГода, 1, 1);
	Элементы.Календарь.КонецПериодаОтображения	= Дата(НомерТекущегоГода, 12, 31);
		
КонецПроцедуры

&НаКлиенте
Процедура НомерТекущегоГодаПриИзмененииЗавершение(Ответ, ДополнительныеПараметры) Экспорт
	
	ОбработатьИзменениеГода(Ответ = КодВозвратаДиалога.Да);
	Модифицированность = Ложь;
	Элементы.Календарь.Обновить();
	
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьДеньЗавершение(ВыбранныйЭлемент, ВыделенныеДаты) Экспорт
	
	Если ВыбранныйЭлемент <> Неопределено Тогда
		ИзменитьВидыДней(ВыделенныеДаты, ВыбранныйЭлемент.Значение);
		Элементы.Календарь.Обновить();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПечатьЗавершение(ОтветНаПредложениеЗаписать, ПараметрыВыполнения = Неопределено) Экспорт
	
	Если ОтветНаПредложениеЗаписать <> -1 Тогда
		Если ОтветНаПредложениеЗаписать <> КодВозвратаДиалога.Да Тогда
			Возврат;
		КонецЕсли;
		Записан = Записать();
		Если Не Записан Тогда
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	ПараметрыПечати = Новый Структура;
	ПараметрыПечати.Вставить("ПроизводственныйКалендарь", Объект.Ссылка);
	ПараметрыПечати.Вставить("НомерГода", НомерТекущегоГода);
	
	ПараметрКоманды = Новый Массив;
	ПараметрКоманды.Добавить(Объект.Ссылка);
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.Печать") Тогда
		МодульУправлениеПечатьюКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("УправлениеПечатьюКлиент");
		МодульУправлениеПечатьюКлиент.ВыполнитьКомандуПечати("Справочник.ПроизводственныеКалендари", "ПроизводственныйКалендарь", 
			ПараметрКоманды, ЭтотОбъект, ПараметрыПечати);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьСвойстваПоляБазовогоКалендаря(Форма)
	
	ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
		Форма.Элементы, 
		"БазовыйКалендарь", 
		"Доступность", 
		Форма.ЕстьБазовыйКалендарь);
		
	ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
		Форма.Элементы, 
		"БазовыйКалендарь", 
		"АвтоОтметкаНеЗаполненного", 
		Форма.ЕстьБазовыйКалендарь);
		
	ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
		Форма.Элементы, 
		"БазовыйКалендарь", 
		"ОтметкаНеЗаполненного", 
		Не ЗначениеЗаполнено(Форма.Объект.БазовыйКалендарь));
	
КонецПроцедуры

&НаКлиенте
Процедура НачатьУстановкуВидимостиБазовогоКалендаря()
	
	ДлительнаяОперация = ЗагрузитьСписокПоддерживаемыхПроизводственныхКалендарей();
	
	ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
	
	ОповещениеОЗавершении = Новый ОписаниеОповещения("ЗавершитьУстановкуВидимостиБазовогоКалендаря", ЭтотОбъект);
	ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОповещениеОЗавершении, ПараметрыОжидания);
	
КонецПроцедуры

&НаСервере
Функция ЗагрузитьСписокПоддерживаемыхПроизводственныхКалендарей()
	
	ПараметрыПроцедуры = Новый Структура;
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НСтр("ru = 'Заполнение списка поддерживаемых календарей'");
	
	Возврат ДлительныеОперации.ВыполнитьВФоне("Справочники.ПроизводственныеКалендари.ЗаполнитьПроизводственныеКалендариПоУмолчаниюДлительнаяОперация", 
		ПараметрыПроцедуры, ПараметрыВыполнения);
	
КонецФункции

&НаКлиенте
Процедура ЗавершитьУстановкуВидимостиБазовогоКалендаря(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Тогда
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "БазовыйКалендарьГруппа", "Видимость", Истина);
		Возврат;
	КонецЕсли;
	
	АдресКалендарей = Результат.АдресРезультата;
	ЭтоПоставляемыйКалендарь = ЕстьПоставляемыйКалендарьСТакимКодом(АдресКалендарей, Объект.Код);
	
	Если Не ЭтоПоставляемыйКалендарь Тогда
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "БазовыйКалендарьГруппа", "Видимость", Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ЕстьПоставляемыйКалендарьСТакимКодом(АдресКалендарей, Код)
	
	ТаблицаКалендарей = ПолучитьИзВременногоХранилища(АдресКалендарей);
	
	Если ТаблицаКалендарей <> Неопределено И ТаблицаКалендарей.Колонки.Найти("Code") <> Неопределено Тогда
		Возврат ТаблицаКалендарей.Найти(СокрЛП(Код), "Code") <> Неопределено;
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ДеньНеделиВФормулировкеСКакогоПереносим(Дата)
	
	Соответствие = Новый Соответствие;
	Соответствие.Вставить(1, НСтр("ru = 'понедельника'"));
	Соответствие.Вставить(2, НСтр("ru = 'вторника'"));
	Соответствие.Вставить(3, НСтр("ru = 'среды'"));
	Соответствие.Вставить(4, НСтр("ru = 'четверга'"));
	Соответствие.Вставить(5, НСтр("ru = 'пятницы'"));
	Соответствие.Вставить(6, НСтр("ru = 'субботы'"));
	Соответствие.Вставить(7, НСтр("ru = 'воскресенья'"));
	
	Представление = Соответствие[ДеньНедели(Дата)];
	Если Представление = Неопределено Тогда
		Возврат Формат(Дата, "ДФ='дддд'"); // АПК:1367 В данном случае отображение дня недели будет корректным с учетом локализации
	КонецЕсли;
	
	Возврат Представление;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ДеньНеделиВФормулировкеНаКакойПереносим(Дата)
	
	Соответствие = Новый Соответствие;
	Соответствие.Вставить(1, НСтр("ru = 'понедельник'"));
	Соответствие.Вставить(2, НСтр("ru = 'вторник'"));
	Соответствие.Вставить(3, НСтр("ru = 'среду'"));
	Соответствие.Вставить(4, НСтр("ru = 'четверг'"));
	Соответствие.Вставить(5, НСтр("ru = 'пятницу'"));
	Соответствие.Вставить(6, НСтр("ru = 'субботу'"));
	Соответствие.Вставить(7, НСтр("ru = 'воскресенье'"));
	
	Представление = Соответствие[ДеньНедели(Дата)];
	Если Представление = Неопределено Тогда
		Возврат Формат(Дата, "ДФ='дддд'"); // АПК:1367 В данном случае отображение дня недели будет корректным с учетом локализации
	КонецЕсли;
	
	Возврат Представление;
	
КонецФункции

&НаСервере
Процедура ПрочитатьНерабочиеДаты(ТекущийОбъект = Неопределено)
	
	Если ТекущийОбъект = Неопределено Тогда
		ТекущийОбъект = Объект;
	КонецЕсли;

	Даты = Новый Массив;
	
	ПроизводственныйКалендарь = ?(ЗначениеЗаполнено(Объект.БазовыйКалендарь), 
		ТекущийОбъект.БазовыйКалендарь, ТекущийОбъект.Ссылка);

	Если ЗначениеЗаполнено(ПроизводственныйКалендарь) Тогда
		Периоды = КалендарныеГрафики.ПериодыНерабочихДней(
			ПроизводственныйКалендарь, Новый СтандартныйПериод(Дата(НомерТекущегоГода, 1, 1), Дата(НомерТекущегоГода, 12, 31)));
		Пояснение = "";
		Для Каждого ОписаниеПериода Из Периоды Цикл
			ОбщегоНазначенияКлиентСервер.ДополнитьМассив(Даты, ОписаниеПериода.Даты);
				Пояснение = Пояснение + ?(Не ПустаяСтрока(Пояснение), Символы.ПС, "") + ОписаниеПериода.Представление;
		КонецЦикла;
		Элементы.НерабочиеПериодыТекст.Заголовок = Пояснение;
	КонецЕсли;
	
	НерабочиеДаты = Новый ФиксированныйМассив(Даты);
	Элементы.НерабочиеПериодыГруппа.Видимость = НерабочиеДаты.Количество() > 0;
	
КонецПроцедуры

#КонецОбласти
