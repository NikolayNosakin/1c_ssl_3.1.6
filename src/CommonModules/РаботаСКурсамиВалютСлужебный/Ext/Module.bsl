﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Загрузить полный список курсов за все время.
//
Процедура ЗагрузитьКурсы() Экспорт
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.ПоставляемыеДанные") Тогда
		Возврат;
	КонецЕсли;
	
	МодульПоставляемыеДанные = ОбщегоНазначения.ОбщийМодуль("ПоставляемыеДанные");
	
	Дескрипторы = МодульПоставляемыеДанные.ДескрипторыПоставляемыхДанныхИзМенеджера("КурсыВалют");
	
	Если Дескрипторы.Descriptor.Количество() < 1 Тогда
		ВызватьИсключение(НСтр("ru = 'В менеджере сервиса отсутствуют данные вида ""КурсыВалют""'"));
	КонецЕсли;
	
	Курсы = МодульПоставляемыеДанные.СсылкиПоставляемыхДанныхИзКэша("КурсыОднойВалюты");
	Для каждого Курс Из Курсы Цикл
		МодульПоставляемыеДанные.УдалитьПоставляемыеДанныеИзКэша(Курс);
	КонецЦикла; 
	
	МодульПоставляемыеДанные.ЗагрузитьИОбработатьДанные(Дескрипторы.Descriptor[0]);
	
КонецПроцедуры

// Вызывается при изменении способа установки курса валюты.
//
// Параметры:
//  Валюта - СправочникСсылка.Валюты
//
Процедура ЗапланироватьКопированиеКурсовВалюты(Знач Валюта) Экспорт
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.ОчередьЗаданий")
		Или Валюта.СпособУстановкиКурса <> Перечисления.СпособыУстановкиКурсаВалюты.ЗагрузкаИзИнтернета Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыМетода = Новый Массив;
	ПараметрыМетода.Добавить(Валюта.Код);

	ПараметрыЗадания = Новый Структура;
	ПараметрыЗадания.Вставить("ИмяМетода", "РаботаСКурсамиВалютСлужебный.КопироватьКурсыВалюты");
	ПараметрыЗадания.Вставить("Параметры", ПараметрыМетода);
	
	МодульОчередьЗаданий = ОбщегоНазначения.ОбщийМодуль("ОчередьЗаданий");
	
	УстановитьПривилегированныйРежим(Истина);
	МодульОчередьЗаданий.ДобавитьЗадание(ПараметрыЗадания);

КонецПроцедуры

// Вызывается после загрузки данных в область или при изменении способа установки курса валюты.
// Копирует курсы одной валюты за все даты из 
// неразделенного xml файла в разделенный регистр.
// 
// Параметры:
//  КодВалюты - Строка
//
Процедура КопироватьКурсыВалюты(Знач КодВалюты) Экспорт
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.ПоставляемыеДанные") Тогда
		Возврат;
	КонецЕсли;
	
	МодульПоставляемыеДанные = ОбщегоНазначения.ОбщийМодуль("ПоставляемыеДанные");
	
	ВалютаСсылка = Справочники.Валюты.НайтиПоКоду(КодВалюты);
	Если ВалютаСсылка.Пустая() Тогда
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Валюта с кодом %1 не найдена в справочнике, загрузка курсов отменена.'"), КодВалюты);
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Поставляемые данные.Распространение курсов валют по областям данных'", ОбщегоНазначения.КодОсновногоЯзыка()),
			УровеньЖурналаРегистрации.Ошибка,,,
			ТекстОшибки);
		Возврат;
	КонецЕсли;
	
	Фильтр = Новый Массив;
	Фильтр.Добавить(Новый Структура("Код, Значение", "Валюта", КодВалюты));
	Курсы = МодульПоставляемыеДанные.СсылкиПоставляемыхДанныхИзКэша("КурсыОднойВалюты", Фильтр);
	Если Курсы.Количество() = 0 Тогда
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Отсутствуют курсы для валюты с кодом %1 в поставляемых данных.'"), КодВалюты);
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Поставляемые данные.Распространение курсов валют по областям данных'", ОбщегоНазначения.КодОсновногоЯзыка()),
			УровеньЖурналаРегистрации.Ошибка,,,
			ТекстОшибки);
		Возврат;
	КонецЕсли;
	
	ПутьКФайлу = ПолучитьИмяВременногоФайла();
	МодульПоставляемыеДанные.ПоставляемыеДанныеИзКэша(Курсы[0]).Записать(ПутьКФайлу);
	ТаблицаКурсов = ПрочитатьТаблицуКурсов(ПутьКФайлу, Истина);
	УдалитьФайлы(ПутьКФайлу);
	
	ТаблицаКурсов.Колонки.Дата.Имя = "Период";
	ТаблицаКурсов.Колонки.Добавить("Валюта");
	ТаблицаКурсов.ЗаполнитьЗначения(ВалютаСсылка, "Валюта");
	
	НачатьТранзакцию();
	Попытка
		РегистрыСведений.КурсыВалют.УстановитьИспользованиеИтогов(Ложь);
		
		НаборЗаписей = РегистрыСведений.КурсыВалют.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Валюта.Установить(ВалютаСсылка);
		НаборЗаписей.Загрузить(ТаблицаКурсов);
		НаборЗаписей.ОбменДанными.Загрузка = Истина;
		
		НаборЗаписей.Записать();
		
		РегистрыСведений.КурсыВалют.УстановитьИспользованиеИтогов(Истина);
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	РегистрыСведений.КурсыВалют.ПересчитатьИтоги();
	
	// Проверка наличие установленного курса и кратности валюты на 1 января 1980 года.
	РаботаСКурсамиВалют.ПроверитьКорректностьКурсаНа01_01_1980(ВалютаСсылка);

КонецПроцедуры

// Вызывается после загрузки данных в область.
// Обновляет курсы валют из поставляемых данных.
//
Процедура ОбновитьКурсыВалют() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Валюты.Код
	|ИЗ
	|	Справочник.Валюты КАК Валюты
	|ГДЕ
	|	Валюты.СпособУстановкиКурса = ЗНАЧЕНИЕ(Перечисление.СпособыУстановкиКурсаВалюты.ЗагрузкаИзИнтернета)";
	Выборка = Запрос.Выполнить().Выбрать();
	
	// Копируем курсы. Это необходимо делать синхронно, т.к. за вызовом ОбновитьКурсыВалют
	// следует обновление ИБ, которое пытается заблокировать базу. Копирование курсов - 
	// длительный процесс, который в асинхронном режиме может начаться в произвольный момент
	// и помешать блокировке.
	Пока Выборка.Следующий() Цикл
		КопироватьКурсыВалюты(Выборка.Код);
	КонецЦикла;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// Вызывается при получении уведомления о новых данных.
// В теле следует проверить, необходимы ли эти данные приложению, 
// и если да - установить флажок Загружать.
// 
// Параметры:
//   Дескриптор - ОбъектXDTO - дескриптор.
//   Загружать - Булево - Истина, если загружать, Ложь - иначе.
//
Процедура ДоступныНовыеДанные(Знач Дескриптор, Загружать) Экспорт
	
	// При получении КурсыВалютЗаДень данные из файла дописываются ко всем хранящимся курсам по валюте
	// и записываются во все области данных, для валют, упоминающихся в области. Записывается только курс за
	// данную дату.
	//
	Если Дескриптор.DataType = "КурсыВалютЗаДень" Тогда
		Загружать = Истина;
	// Данные КурсыВалют приходят к нам в трех случаях - 
	// при подключении ИБ к МС, 
	// при обновлении ИБ, когда после обновления потребовались валюты, которые были не нужны до этого
	// при ручной загрузке файла курсов в МС.
	// Во всех случаях сбрасываем кэш, перезаписываются все курсы во всех областях данных.
	ИначеЕсли Дескриптор.DataType = "КурсыВалют" Тогда
		Загружать = Истина;
	КонецЕсли;
	
КонецПроцедуры

// Вызывается после вызова ДоступныНовыеДанные, позволяет разобрать данные.
//
// Параметры:
//   Дескриптор - ОбъектXDTO - дескриптор.
//   ПутьКФайлу - Строка - полное имя извлеченного файла. Файл будет автоматически удален 
//                  после завершения процедуры. Если в менеджере сервиса не был
//                  указан файл - значение аргумента равно Неопределено.
//
Процедура ОбработатьНовыеДанные(Знач Дескриптор, Знач ПутьКФайлу) Экспорт
	
	Если Дескриптор.DataType = "КурсыВалютЗаДень" Тогда
		ОбработатьПоставляемыеКурсыЗаДень(Дескриптор, ПутьКФайлу);
	ИначеЕсли Дескриптор.DataType = "КурсыВалют" Тогда
		ОбработатьПоставляемыеКурсы(Дескриптор, ПутьКФайлу);
	КонецЕсли;
	
КонецПроцедуры

// Вызывается при отмене обработки данных в случае сбоя.
//
// Параметры:
//   Дескриптор - ОбъектXDTO - дескриптор.
//
Процедура ОбработкаДанныхОтменена(Знач Дескриптор) Экспорт 
	
	Если ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.ПоставляемыеДанные") Тогда
		МодульПоставляемыеДанные = ОбщегоНазначения.ОбщийМодуль("ПоставляемыеДанные");
		МодульПоставляемыеДанные.ОбластьОбработана(Дескриптор.FileGUID, "КурсыВалютЗаДень", Неопределено);
	КонецЕсли;
	
КонецПроцедуры

// См. ОчередьЗаданийПереопределяемый.ПриОпределенииПсевдонимовОбработчиков.
Процедура ПриОпределенииПсевдонимовОбработчиков(СоответствиеИменПсевдонимам) Экспорт
	
	СоответствиеИменПсевдонимам.Вставить("РаботаСКурсамиВалютСлужебный.КопироватьКурсыВалюты");
	СоответствиеИменПсевдонимам.Вставить("РаботаСКурсамиВалютСлужебный.ОбновитьКурсыВалют");
	
КонецПроцедуры

// См. ПоставляемыеДанныеПереопределяемый.ПолучитьОбработчикиПоставляемыхДанных.
Процедура ПриОпределенииОбработчиковПоставляемыхДанных(Обработчики) Экспорт
	
	ЗарегистрироватьОбработчикиПоставляемыхДанных(Обработчики);
	
КонецПроцедуры

// См. ВыгрузкаЗагрузкаДанныхПереопределяемый.ПослеЗагрузкиДанных.
Процедура ПослеЗагрузкиДанных(Контейнер) Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.ПоставляемыеДанные") Тогда
		// Создаем связи между разделенными и неразделенными валютами, копируем курсы.
		ОбновитьКурсыВалют();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Регистрирует обработчики поставляемых данных за день и за все время.
//
// Параметры:
//     Обработчики - ТаблицаЗначений - таблица для добавления обработчиков. Содержит колонки:
//       * ВидДанных - Строка - код вида данных, обрабатываемый обработчиком.
//       * КодОбработчика - Строка - будет использоваться при восстановлении обработки данных после сбоя.
//       * Обработчик - ОбщийМодуль - модуль, содержащий экспортные  процедуры:
//                                          ДоступныНовыеДанные(Дескриптор, Загружать) Экспорт  
//                                          ОбработатьНовыеДанные(Дескриптор, ПутьКФайлу) Экспорт
//                                          ОбработкаДанныхОтменена(Дескриптор) Экспорт
//
Процедура ЗарегистрироватьОбработчикиПоставляемыхДанных(Знач Обработчики)
	
	Обработчик = Обработчики.Добавить();
	Обработчик.ВидДанных = "КурсыВалютЗаДень";
	Обработчик.КодОбработчика = "КурсыВалютЗаДень";
	Обработчик.Обработчик = РаботаСКурсамиВалютСлужебный;
	
	Обработчик = Обработчики.Добавить();
	Обработчик.ВидДанных = "КурсыВалют";
	Обработчик.КодОбработчика = "КурсыВалют";
	Обработчик.Обработчик = РаботаСКурсамиВалютСлужебный;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Сериализация/десериализация файла курсов.

// Записывает файл в формате поставляемых данных.
//
// Параметры:
//  ТаблицаКурсов - ТаблицаЗначений - с колонками Код, Дата, Кратность, Курс.
//  Файл - Строка, ЗаписьТекста
//
Процедура ЗаписатьТаблицуКурсов(Знач ТаблицаКурсов, Знач Файл)
	
	Если ТипЗнч(Файл) = Тип("Строка") Тогда
		ЗаписьТекста = Новый ЗаписьТекста(Файл);
	Иначе
		ЗаписьТекста = Файл;
	КонецЕсли;
	
	Для каждого СтрокаТаблицы Из ТаблицаКурсов Цикл
			
		КурсXML = СтрЗаменить(
		СтрЗаменить(
		СтрЗаменить(
			СтрЗаменить("<Rate Code=""%1"" Date=""%2"" Factor=""%3"" Rate=""%4""/>", 
			"%1", СтрокаТаблицы.Код),
			"%2", Лев(СериализаторXDTO.XMLСтрока(СтрокаТаблицы.Дата), 10)),
			"%3", СериализаторXDTO.XMLСтрока(СтрокаТаблицы.Кратность)),
			"%4", СериализаторXDTO.XMLСтрока(СтрокаТаблицы.Курс));
		
		ЗаписьТекста.ЗаписатьСтроку(КурсXML);
	КонецЦикла; 
	
	Если ТипЗнч(Файл) = Тип("Строка") Тогда
		ЗаписьТекста.Закрыть();
	КонецЕсли;
	
КонецПроцедуры

// Читает файл в формате поставляемых данных.
//
// Параметры:
//  ПутьКФайлу - Строка - имя файла.
//  ИскатьДубликаты - Булево - сворачивает записи с одинаковой датой.
//
// Возвращаемое значение
//  ТаблицаЗначений - с колонками Код, Дата, Кратность, Курс.
//
Функция ПрочитатьТаблицуКурсов(Знач ПутьКФайлу, Знач ИскатьДубликаты = Ложь)
	
	ТипДанныхКурса = ФабрикаXDTO.Тип("http://www.1c.ru/SaaS/SuppliedData/CurrencyRates", "Rate");
	ТаблицаКурсов = Новый ТаблицаЗначений();
	ТаблицаКурсов.Колонки.Добавить("Код", Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(200)));
	ТаблицаКурсов.Колонки.Добавить("Дата", Новый ОписаниеТипов("Дата", , , Новый КвалификаторыДаты(ЧастиДаты.Дата)));
	ТаблицаКурсов.Колонки.Добавить("Кратность", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(9, 0)));
	ТаблицаКурсов.Колонки.Добавить("Курс", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(20, 4)));
	
	Чтение = Новый ЧтениеТекста(ПутьКФайлу);
	ТекущаяСтрока = Чтение.ПрочитатьСтроку();
	Пока ТекущаяСтрока <> Неопределено Цикл
		
		ЧтениеXML = Новый ЧтениеXML();
		ЧтениеXML.УстановитьСтроку(ТекущаяСтрока);
		Курс = ФабрикаXDTO.ПрочитатьXML(ЧтениеXML, ТипДанныхКурса);
		
		Если ИскатьДубликаты Тогда
			Для каждого Дубликат Из ТаблицаКурсов.НайтиСтроки(Новый Структура("Дата", Курс.Date)) Цикл
				ТаблицаКурсов.Удалить(Дубликат);
			КонецЦикла;
		КонецЕсли;
		
		ЗаписьКурсовВалют = ТаблицаКурсов.Добавить();
		ЗаписьКурсовВалют.Код    = Курс.Code;
		ЗаписьКурсовВалют.Дата    = Курс.Date;
		ЗаписьКурсовВалют.Кратность = Курс.Factor;
		ЗаписьКурсовВалют.Курс      = Курс.Rate;

		ТекущаяСтрока = Чтение.ПрочитатьСтроку();
	КонецЦикла;
	Чтение.Закрыть();
	
	ТаблицаКурсов.Индексы.Добавить("Код");
	Возврат ТаблицаКурсов;
		
КонецФункции

// Вызывается, когда получены данные вида "КурсыВалют".
//
// Параметры:
//   Дескриптор   - ОбъектXDTO Descriptor.
//   ПутьКФайлу   - Строка - полное имя извлеченного файла.
//
Процедура ОбработатьПоставляемыеКурсы(Знач Дескриптор, Знач ПутьКФайлу)
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.ПоставляемыеДанные") Тогда
		Возврат;
	КонецЕсли;
	
	МодульПоставляемыеДанные = ОбщегоНазначения.ОбщийМодуль("ПоставляемыеДанные");
	ТаблицаКурсов = ПрочитатьТаблицуКурсов(ПутьКФайлу);
	
	// Разбиваем на файлы по валюте и записываем в базу.
	ТаблицаКодов = ТаблицаКурсов.Скопировать( , "Код");
	ТаблицаКодов.Свернуть("Код");
	Для каждого СтрокаКода Из ТаблицаКодов Цикл
		
		ИмяВременногоФайла = ПолучитьИмяВременногоФайла();
		ЗаписатьТаблицуКурсов(ТаблицаКурсов.НайтиСтроки(Новый Структура("Код", СтрокаКода.Код)), ИмяВременногоФайла);
		
		ДескрипторКэша = Новый Структура;
		ДескрипторКэша.Вставить("ВидДанных", "КурсыОднойВалюты");
		ДескрипторКэша.Вставить("ДатаДобавления", ТекущаяУниверсальнаяДата());
		ДескрипторКэша.Вставить("ИдентификаторФайла", Новый УникальныйИдентификатор);
		ДескрипторКэша.Вставить("Характеристики", Новый Массив);
		
		ДескрипторКэша.Характеристики.Добавить(Новый Структура("Код, Значение, Ключевая", "Валюта", СтрокаКода.Код, Истина));
		
		МодульПоставляемыеДанные.СохранитьПоставляемыеДанныеВКэш(ДескрипторКэша, ИмяВременногоФайла);
		УдалитьФайлы(ИмяВременногоФайла);
		
	КонецЦикла;
	
	ОбластиДляОбновления = МодульПоставляемыеДанные.ОбластиТребующиеОбработки(
		Дескриптор.FileGUID, "КурсыВалют");
	
	РаспространитьКурсыПоОД(Неопределено, ТаблицаКурсов, ОбластиДляОбновления, 
		Дескриптор.FileGUID, "КурсыВалют");

КонецПроцедуры

// Вызывается после получения новых данных вида КурсыВалютЗаДень.
//
// Параметры:
//   Дескриптор   - ОбъектXDTO Descriptor.
//   ПутьКФайлу   - Строка - полное имя извлеченного файла.
//
Процедура ОбработатьПоставляемыеКурсыЗаДень(Знач Дескриптор, Знач ПутьКФайлу)
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.ПоставляемыеДанные") Тогда
		Возврат;
	КонецЕсли;
	
	МодульПоставляемыеДанные = ОбщегоНазначения.ОбщийМодуль("ПоставляемыеДанные");
	
	ТаблицаКурсов = ПрочитатьТаблицуКурсов(ПутьКФайлу);
	
	ДатаКурсов = "";
	Для каждого Характеристика Из Дескриптор.Properties.Property Цикл
		Если Характеристика.Code = "Дата" Тогда
			ДатаКурсов = Дата(Характеристика.Value); 		
		КонецЕсли;
	КонецЦикла; 
	
	Если ДатаКурсов = "" Тогда
		ВызватьИсключение НСтр("ru = 'Данные вида ""КурсыВалютЗаДень"" не содержат характеристики ""Дата"". Обновление курсов невозможно.'"); 
	КонецЕсли;
	
	ОбластиДляОбновления = МодульПоставляемыеДанные.ОбластиТребующиеОбработки(Дескриптор.FileGUID, "КурсыВалютЗаДень", Истина);
	
	ИндексОбщихКурсов = ОбластиДляОбновления.Найти(-1);
	Если ИндексОбщихКурсов <> Неопределено Тогда
		
		КэшКурсов = МодульПоставляемыеДанные.ДескрипторыПоставляемыхДанныхИзКэша("КурсыОднойВалюты", , Ложь);
		Если КэшКурсов.Количество() > 0 Тогда
			Для каждого СтрокаКурсов Из ТаблицаКурсов Цикл
				
				КэшТекущей = Неопределено;
				Для	каждого ДескрипторКэша Из КэшКурсов Цикл
					Если ДескрипторКэша.Характеристики.Количество() > 0 
						И ДескрипторКэша.Характеристики[0].Код = "Валюта"
						И ДескрипторКэша.Характеристики[0].Значение = СтрокаКурсов.Код Тогда
						КэшТекущей = ДескрипторКэша;
						Прервать;
					КонецЕсли;
				КонецЦикла;
				
				ИмяВременногоФайла = ПолучитьИмяВременногоФайла();
				Если КэшТекущей <> Неопределено Тогда
					Данные = МодульПоставляемыеДанные.ПоставляемыеДанныеИзКэша(КэшТекущей.ИдентификаторФайла);
					Данные.Записать(ИмяВременногоФайла);
				Иначе
					КэшТекущей = Новый Структура;
					КэшТекущей.Вставить("ВидДанных", "КурсыОднойВалюты");
					КэшТекущей.Вставить("ДатаДобавления", ТекущаяУниверсальнаяДата());
					КэшТекущей.Вставить("ИдентификаторФайла", Новый УникальныйИдентификатор);
					КэшТекущей.Вставить("Характеристики", Новый Массив);
					
					КэшТекущей.Характеристики.Добавить(Новый Структура("Код, Значение, Ключевая", "Валюта", СтрокаКурсов.Код, Истина));
				КонецЕсли;
				
				ЗаписьТекста = Новый ЗаписьТекста(ИмяВременногоФайла, КодировкаТекста.UTF8, 
				Символы.ПС, Истина);
				
				ТаблицаДляЗаписи = Новый Массив;
				ТаблицаДляЗаписи.Добавить(СтрокаКурсов);
				ЗаписатьТаблицуКурсов(ТаблицаДляЗаписи, ЗаписьТекста);
				ЗаписьТекста.Закрыть();
				
				МодульПоставляемыеДанные.СохранитьПоставляемыеДанныеВКэш(КэшТекущей, ИмяВременногоФайла);
				УдалитьФайлы(ИмяВременногоФайла);
			КонецЦикла;
			
		КонецЕсли;
		
		ОбластиДляОбновления.Удалить(ИндексОбщихКурсов);
	КонецЕсли;
	
	РаспространитьКурсыПоОД(ДатаКурсов, ТаблицаКурсов, ОбластиДляОбновления, 
		Дескриптор.FileGUID, "КурсыВалютЗаДень");

КонецПроцедуры

// Копирует курсы во все ОД
//
// Параметры:
//  ДатаКурсов - Дата, Неопределено - курсы добавляются за указанную дату либо за все время.
//  ТаблицаКурсов - ТаблицаЗначений с курсами.
//  ОбластиДляОбновления - массив со списком кодов областей.
//  ИдентификаторФайла - УникальныйИдентификатор файла обрабатываемых курсов.
//  КодОбработчика - Строка - код обработчика.
//
Процедура РаспространитьКурсыПоОД(Знач ДатаКурсов, Знач ТаблицаКурсов, Знач ОбластиДляОбновления, Знач ИдентификаторФайла, Знач КодОбработчика)
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.БазоваяФункциональность") Тогда
		Возврат;
	КонецЕсли;
	
	МодульПоставляемыеДанные = ОбщегоНазначения.ОбщийМодуль("ПоставляемыеДанные");
	МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
	
	ВалютыОбластей = Новый Соответствие();
	
	ЗапросОбщий = Новый Запрос();
	ЗапросОбщий.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	ЗапросОбщий.УстановитьПараметр("ПоставляемыеКурсы", ТаблицаКурсов);
	ЗапросОбщий.УстановитьПараметр("ТолькоЗаОдинДень", ДатаКурсов <> Неопределено);
	ЗапросОбщий.УстановитьПараметр("ДатаКурсов", ДатаКурсов);
	ЗапросОбщий.УстановитьПараметр("НачалоПоставкиКурсов", Дата("19800101"));
	
	Для каждого ОбластьДанных Из ОбластиДляОбновления Цикл
		
		Попытка
			МодульРаботаВМоделиСервиса.ВойтиВОбластьДанных(ОбластьДанных);
		Исключение
			МодульРаботаВМоделиСервиса.ВыйтиИзОбластиДанных();
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Не удалось установить разделение сеанса %1 по причине:
				|%2'", ОбщегоНазначения.КодОсновногоЯзыка()),
				Формат(ОбластьДанных, "ЧН=0; ЧГ=0"),
				ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			
			ЗаписьЖурналаРегистрации(НСтр("ru = 'Поставляемые данные.Распространение курсов валют по областям данных'", ОбщегоНазначения.КодОсновногоЯзыка()),
				УровеньЖурналаРегистрации.Ошибка,,,
				ТекстОшибки);
				
			ЗапланироватьОбновлениеКурсовВалют(ОбластьДанных);
			Продолжить;
			
		КонецПопытки;
		
		ВалютыОбластейСтрокой = ОбщегоНазначения.ЗначениеВСтрокуXML(ВалютыОбластей);
		
		НачатьТранзакцию();
		Попытка
			
			ОбработатьКурсыОбластиВТранзакции(ЗапросОбщий, ВалютыОбластей, ТаблицаКурсов);
			МодульРаботаВМоделиСервиса.ВыйтиИзОбластиДанных();
			МодульПоставляемыеДанные.ОбластьОбработана(ИдентификаторФайла, КодОбработчика, ОбластьДанных);

			ЗафиксироватьТранзакцию();
			
		Исключение
			
			ОтменитьТранзакцию();
			
			ВалютыОбластей = ОбщегоНазначения.ЗначениеИзСтрокиXML(ВалютыОбластейСтрокой);
			МодульРаботаВМоделиСервиса.ВыйтиИзОбластиДанных();
			
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Не удалось обновить курсы валют в области %1 по причине:
				|%2'", ОбщегоНазначения.КодОсновногоЯзыка()),
				Формат(ОбластьДанных, "ЧН=0; ЧГ=0"),
				ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			ЗаписьЖурналаРегистрации(НСтр("ru = 'Поставляемые данные.Распространение курсов валют по областям данных'", ОбщегоНазначения.КодОсновногоЯзыка()),
				УровеньЖурналаРегистрации.Ошибка,,,
				ТекстОшибки);
			
		КонецПопытки;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗапланироватьОбновлениеКурсовВалют(ОбластьДанных)

	Если Не ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.ОчередьЗаданий") Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыЗадания = Новый Структура;
	ПараметрыЗадания.Вставить("ИмяМетода", "РаботаСКурсамиВалютСлужебный.ОбновитьКурсыВалют");
	ПараметрыЗадания.Вставить("ОбластьДанных", ОбластьДанных);
	
	МодульОчередьЗаданий = ОбщегоНазначения.ОбщийМодуль("ОчередьЗаданий");
	
	УстановитьПривилегированныйРежим(Истина);
	МодульОчередьЗаданий.ДобавитьЗадание(ПараметрыЗадания);

КонецПроцедуры

Функция СвойстваПоставляемойВалюты(ВалютыОбластей, КодВалюты, ТаблицаКурсов, ЗапросОбщий)
	
	СвойстваВалюты = ВалютыОбластей.Получить(КодВалюты);
	
	Если СвойстваВалюты <> Неопределено Тогда 
		
		Возврат СвойстваВалюты;
		
	КонецЕсли;
	
	ПоставляемыеКурсы = ТаблицаКурсов.Скопировать(Новый Структура("Код", КодВалюты));
	
	СвойстваВалюты = Новый Структура("Поставляемая, ПорядковыйНомер", Ложь, Неопределено);
	
	Если ПоставляемыеКурсы.Количество() = 0 Тогда
		
		ВалютыОбластей.Вставить(КодВалюты, СвойстваВалюты);
		Возврат СвойстваВалюты;
		
	КонецЕсли;
	
	ПорядковыйНомер = Формат(ЗапросОбщий.МенеджерВременныхТаблиц.Таблицы.Количество() + 1, "ЧН=0; ЧГ=0");
	
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	ПоставляемыеКурсы.Дата КАК Дата,
	|	ПоставляемыеКурсы.Кратность КАК Кратность,
	|	ПоставляемыеКурсы.Курс КАК Курс
	|ПОМЕСТИТЬ КурсыВалютыNNN
	|ИЗ
	|	&ПоставляемыеКурсы КАК ПоставляемыеКурсы
	|ГДЕ
	|	ПоставляемыеКурсы.Код = &КодВалюты
	|	И ПоставляемыеКурсы.Дата > &НачалоПоставкиКурсов
	|	И ВЫБОР
	|			КОГДА &ТолькоЗаОдинДень
	|				ТОГДА ПоставляемыеКурсы.Дата = &ДатаКурсов
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ";
	
	ЗапросОбщий.Текст = СтрЗаменить(ТекстЗапроса, "NNN", ПорядковыйНомер);
	ЗапросОбщий.Выполнить();
	
	СвойстваВалюты.Поставляемая = Истина;
	СвойстваВалюты.ПорядковыйНомер = ПорядковыйНомер;
	
	ВалютыОбластей.Вставить(КодВалюты, СвойстваВалюты);
	
	Возврат СвойстваВалюты;
	
КонецФункции

Процедура ОбработатьКурсыОбластиВТранзакции(ЗапросОбщий, ВалютыОбластей, ТаблицаКурсов)
	
	ЗапросВалюты = Новый Запрос;
	ЗапросВалюты.Текст = 
	"ВЫБРАТЬ
	|	Валюты.Ссылка,
	|	Валюты.Код
	|ИЗ
	|	Справочник.Валюты КАК Валюты
	|ГДЕ
	|	Валюты.СпособУстановкиКурса = ЗНАЧЕНИЕ(Перечисление.СпособыУстановкиКурсаВалюты.ЗагрузкаИзИнтернета)";
	
	ВыборкаВалюты = ЗапросВалюты.Выполнить().Выбрать(); // АПК:1328 - блокировка не требуется.
	
	Пока ВыборкаВалюты.Следующий() Цикл
		
		ЗапросОбщий.УстановитьПараметр("Валюта", ВыборкаВалюты.Ссылка);
		ЗапросОбщий.УстановитьПараметр("КодВалюты", ВыборкаВалюты.Код);
		
		СвойстваВалюты = СвойстваПоставляемойВалюты(ВалютыОбластей, ВыборкаВалюты.Код, ТаблицаКурсов, ЗапросОбщий);
		
		Если НЕ СвойстваВалюты.Поставляемая Тогда
			Продолжить;
		КонецЕсли;
		
		ТекстЗапроса = 
		"ВЫБРАТЬ
		|	Сравнение.Дата КАК Дата,
		|	Сравнение.Кратность КАК Кратность,
		|	Сравнение.Курс КАК Курс,
		|	МАКСИМУМ(Сравнение.ВФайле) КАК ВФайле,
		|	МАКСИМУМ(Сравнение.ВДанных) КАК ВДанных
		|ИЗ
		|	(ВЫБРАТЬ
		|		ПоставляемыеКурсы.Дата КАК Дата,
		|		ПоставляемыеКурсы.Кратность КАК Кратность,
		|		ПоставляемыеКурсы.Курс КАК Курс,
		|		1 КАК ВФайле,
		|		0 КАК ВДанных
		|	ИЗ
		|		КурсыВалютыNNN КАК ПоставляемыеКурсы
		|	
		|	ОБЪЕДИНИТЬ ВСЕ
		|	
		|	ВЫБРАТЬ
		|		КурсыВалют.Период,
		|		КурсыВалют.Кратность,
		|		КурсыВалют.Курс,
		|		0,
		|		1
		|	ИЗ
		|		РегистрСведений.КурсыВалют КАК КурсыВалют
		|	ГДЕ
		|		КурсыВалют.Валюта = &Валюта
		|		И КурсыВалют.Период > &НачалоПоставкиКурсов
		|		И ВЫБОР
		|				КОГДА &ТолькоЗаОдинДень
		|					ТОГДА КурсыВалют.Период = &ДатаКурсов
		|				ИНАЧЕ ИСТИНА
		|			КОНЕЦ) КАК Сравнение
		|
		|СГРУППИРОВАТЬ ПО
		|	Сравнение.Дата,
		|	Сравнение.Кратность,
		|	Сравнение.Курс
		|
		|ИМЕЮЩИЕ
		|	МАКСИМУМ(Сравнение.ВФайле) <> МАКСИМУМ(Сравнение.ВДанных)
		|
		|УПОРЯДОЧИТЬ ПО
		|	Дата,
		|	ВДанных";
		
		ЗапросОбщий.Текст = СтрЗаменить(ТекстЗапроса, "NNN", СвойстваВалюты.ПорядковыйНомер);
		
		РезультатОбщий = ЗапросОбщий.Выполнить();
		ВыборкаОбщий = РезультатОбщий.Выбрать();
		
		ТекДата = Неопределено;
		ПерваяИтерацияПоДате = Истина;
		
		Пока ВыборкаОбщий.Следующий() Цикл
			
			Если ТекДата <> ВыборкаОбщий.Дата Тогда
				ПерваяИтерацияПоДате = Истина;
				ТекДата = ВыборкаОбщий.Дата;
			КонецЕсли;
			
			Если НЕ ПерваяИтерацияПоДате Тогда
				Продолжить;
			КонецЕсли;
			
			ПерваяИтерацияПоДате = Ложь;
			
			НаборЗаписей = РегистрыСведений.КурсыВалют.СоздатьНаборЗаписей();
			НаборЗаписей.Отбор.Валюта.Установить(ВыборкаВалюты.Ссылка);
			НаборЗаписей.Отбор.Период.Установить(ВыборкаОбщий.Дата);
			Если НЕ ЗапросОбщий.Параметры.ТолькоЗаОдинДень Тогда
				// Блокируем неэффективное обновление связанных валют.
				НаборЗаписей.ОбменДанными.Загрузка = Истина;
			КонецЕсли;
			
			Если ВыборкаОбщий.ВФайле = 1 Тогда
				
				Запись = НаборЗаписей.Добавить();
				Запись.Валюта = ВыборкаВалюты.Ссылка;
				Запись.Период = ВыборкаОбщий.Дата;
				Запись.Кратность = ВыборкаОбщий.Кратность;
				Запись.Курс = ВыборкаОбщий.Курс;
				
			КонецЕсли;
			
			// Проверяем дату запрета изменений.
			
			Записывать = Истина;
			Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ДатыЗапретаИзменения") Тогда
				МодульДатыЗапретаИзмененияСлужебный = ОбщегоНазначения.ОбщийМодуль("ДатыЗапретаИзмененияСлужебный");
				Если МодульДатыЗапретаИзмененияСлужебный.ЗапретИзмененияПроверяется(Метаданные.РегистрыСведений.КурсыВалют) Тогда
					МодульДатыЗапретаИзменения = ОбщегоНазначения.ОбщийМодуль("ДатыЗапретаИзменения");
					Записывать = Не МодульДатыЗапретаИзменения.ИзменениеЗапрещено(НаборЗаписей);
				КонецЕсли;
			КонецЕсли;
			
			Если Записывать Тогда
				НаборЗаписей.Записать();
			Иначе
				Комментарий = НСтр("ru = 'Загрузка курса валюты %1 на дату %2 отменена из-за нарушения даты запрета изменений.'"); 
				Комментарий = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(Комментарий, ВыборкаВалюты.Код, ВыборкаОбщий.Дата);
				ИмяСобытия = НСтр("ru = 'Поставляемые данные.Отмена загрузки курсов валюты'", ОбщегоНазначения.КодОсновногоЯзыка());
				ЗаписьЖурналаРегистрации(ИмяСобытия, УровеньЖурналаРегистрации.Информация,, ВыборкаВалюты.Ссылка, Комментарий);
			КонецЕсли;
			
		КонецЦикла;
		
		// Проверка наличие установленного курса и кратности валюты на 1 января 1980 года.
		РаботаСКурсамиВалют.ПроверитьКорректностьКурсаНа01_01_1980(ВыборкаВалюты.Ссылка);
		
	КонецЦикла;
	
КонецПроцедуры

Функция ФормыВводаПрописей() Экспорт
	
	КоллекцииФорм = Новый Массив;
	КоллекцииФорм.Добавить(Метаданные.ОбщиеФормы);
	КоллекцииФорм.Добавить(Метаданные.Справочники.Валюты.Формы);
	Если Метаданные.Обработки.Найти("ЗагрузкаКурсовВалют") <> Неопределено Тогда
		КоллекцииФорм.Добавить(Метаданные.Обработки["ЗагрузкаКурсовВалют"].Формы);
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность.Печать") Тогда
		МодульУправлениеПечатьюМультиязычность = ОбщегоНазначения.ОбщийМодуль("УправлениеПечатьюМультиязычность");
		ДопустимыеКодыЯзыков = МодульУправлениеПечатьюМультиязычность.ДоступныеЯзыки();
	Иначе
		ДопустимыеКодыЯзыков = СтандартныеПодсистемыСервер.ЯзыкиКонфигурации();
	КонецЕсли;
	
	НайденныеФормы = Новый Соответствие;
	Для Каждого КодЯзыка Из ДопустимыеКодыЯзыков Цикл
		НайденныеФормы.Вставить(КодЯзыка, "");
	КонецЦикла;
	
	Результат = Новый СписокЗначений;
	
	Для Каждого КоллекцияФорм Из КоллекцииФорм Цикл
		Для Каждого Форма Из КоллекцияФорм Цикл
			ЧастиИмени = СтрРазделить(Форма.Имя, "_", Истина);
			Суффикс = ЧастиИмени[ЧастиИмени.ВГраница()];
			Если НайденныеФормы[Суффикс] <> Неопределено Тогда
				НайденныеФормы[Суффикс] = Форма.ПолноеИмя();
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	ДобавитьФормуПараметрыПрописиВалютыНаДругихЯзыках = Ложь;
	
	Для Каждого КодЯзыка Из ДопустимыеКодыЯзыков Цикл
		Если ЗначениеЗаполнено(НайденныеФормы[КодЯзыка]) Тогда
			Результат.Добавить(КодЯзыка, НайденныеФормы[КодЯзыка]);
		Иначе
			ДобавитьФормуПараметрыПрописиВалютыНаДругихЯзыках = Истина;
		КонецЕсли;
	КонецЦикла;
	
	Если ДобавитьФормуПараметрыПрописиВалютыНаДругихЯзыках Тогда
		Результат.Добавить("", "ПараметрыПрописиВалютыНаДругихЯзыках");
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ПредставлениеЯзыка(КодЯзыка) Экспорт
	
	Представление = ПредставлениеКодаЛокализации(КодЯзыка);
	ЧастиСтроки = СтрРазделить(Представление, " ", Истина);
	ЧастиСтроки[0] = ТРег(ЧастиСтроки[0]);
	Представление = СтрСоединить(ЧастиСтроки, " ");
	
	Возврат Представление;
	
КонецФункции

#КонецОбласти
